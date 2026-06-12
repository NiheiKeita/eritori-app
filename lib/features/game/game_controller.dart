import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../domain/config/game_config.dart';
import '../../domain/mask/sprite_composite.dart';
import '../../domain/models/stage.dart';
import '../../domain/scoring/polygon_math.dart';
import '../../domain/scoring/score_calculator.dart';
import '../../domain/scoring/stroke.dart';
import 'cutout_renderer.dart';
import 'sprite_transform.dart';

/// ゲームの状態遷移（spec §5 / §6.2）。
enum GameStatus { loading, ready, drawing, success, fail }

/// 失敗理由。
enum FailReason { none, touchedFace, notClosed }

/// 確定後の結果（スコア + 切り取り画像）。
class GameResult {
  GameResult({
    required this.score,
    required this.cutoutImage,
    required this.cutoutPng,
    required this.loop,
  });

  final ScoreResult score;
  final ui.Image cutoutImage;
  final Uint8List cutoutPng;
  final List<Offset> loop;
}

/// ゲーム画面の状態とコアロジックを保持する Controller。
///
/// 判定はすべて襟ローカル座標で行う（spec §6.1）。回転レベルでも [tick] で
/// 角度を更新し、変換行列に回転を入れるだけで同一コードが動く。
class GameController extends ChangeNotifier {
  GameController({
    required this.stage,
    ScoreCalculator scoreCalculator = const ScoreCalculator(),
  }) : _scoreCalculator = scoreCalculator;

  final Stage stage;
  final ScoreCalculator _scoreCalculator;

  SpriteComposite? _composite;
  SpriteComposite? get composite => _composite;

  GameStatus _status = GameStatus.loading;
  GameStatus get status => _status;

  FailReason _failReason = FailReason.none;
  FailReason get failReason => _failReason;

  /// 失敗時、顔に触れたローカル座標（演出用, spec §9.3）。
  Offset? _failLocalPoint;
  Offset? get failLocalPoint => _failLocalPoint;

  final Stroke _stroke = Stroke();
  Stroke get stroke => _stroke;

  GameResult? _result;
  GameResult? get result => _result;

  Size _canvasSize = Size.zero;
  double _rotationRadians = 0;
  double get rotationRadians => _rotationRadians;

  SpriteTransform _transform = SpriteTransform.fit(
    canvasSize: const Size(1, 1),
    localWidth: 1,
    localHeight: 1,
  );
  SpriteTransform get transform => _transform;

  /// 静止レベルの初期角度をランダム化する（spec §11: ランダムは1種のみ）。
  void initRandomAngle(math.Random random) {
    if (!stage.rotates) {
      _rotationRadians = (random.nextDouble() - 0.5) * 0.25; // ±約7°
    }
  }

  Future<void> loadAssets(SpriteComposite composite) async {
    _composite = composite;
    _status = GameStatus.ready;
    _rebuildTransform();
    notifyListeners();
  }

  void setCanvasSize(Size size) {
    if (size == _canvasSize) return;
    _canvasSize = size;
    _rebuildTransform();
    notifyListeners();
  }

  /// 回転レベルの角度更新（[dtSeconds] 経過分）。
  void tick(double dtSeconds) {
    if (!stage.rotates) return;
    if (_status == GameStatus.success || _status == GameStatus.fail) return;
    _rotationRadians += stage.rotationSpeed * math.pi / 180 * dtSeconds;
    _rebuildTransform();
    notifyListeners();
  }

  void _rebuildTransform() {
    final c = _composite;
    if (c == null || _canvasSize == Size.zero) return;
    _transform = SpriteTransform.fit(
      canvasSize: _canvasSize,
      localWidth: c.localWidth,
      localHeight: c.localHeight,
      rotationRadians: _rotationRadians,
    );
  }

  // --- ジェスチャ（spec §6.2）---

  void onPanStart(Offset screenPoint) {
    if (_status != GameStatus.ready && _status != GameStatus.drawing) return;
    final c = _composite;
    if (c == null) return;
    _stroke.clear();
    _status = GameStatus.drawing;
    _stroke.add(_transform.toLocal(screenPoint));
    notifyListeners();
  }

  void onPanUpdate(Offset screenPoint) {
    if (_status != GameStatus.drawing) return;
    final c = _composite;
    if (c == null) return;

    // 回転中は毎フレーム最新の変換でローカル化する。
    final local = _transform.toLocal(screenPoint);

    // 失敗判定（最優先）: 今の指先のみを本体マスクと照合（spec §6.2）。
    if (c.lizardMask.isOpaqueAt(local.dx, local.dy)) {
      _failLocalPoint = local;
      _fail(FailReason.touchedFace);
      return;
    }

    // 点の間引き: 前点から一定距離以上離れた時だけ追加（密すぎる点列を防ぐ）。
    final prev = _stroke.last;
    if (prev == null ||
        (local - prev).distance >= GameConfig.minPointDist) {
      _stroke.add(local);
    }

    // 自己交差判定: 最小点数たまってから、最新線分が過去線分と厳密交差したら確定。
    // 退化ループ（面積ほぼゼロ）は detectSelfIntersection 内で除外され確定しない。
    if (_stroke.length >= GameConfig.minPointsBeforeClose) {
      final hit = detectSelfIntersection(
        _stroke.points,
        minGap: GameConfig.minIntersectionGap,
        minLoopArea: GameConfig.minLoopArea,
        tolerance: GameConfig.intersectionToleranceLocal,
      );
      if (hit != null) {
        if (kDebugMode) {
          // 検証用: 確定時の点数・交差線分・ループ面積（早期確定の有無を確認）。
          debugPrint(
            'LOOP confirm: points=${_stroke.length} '
            'segIndex=${hit.segmentIndex} area=${polygonArea(hit.loop).round()}',
          );
        }
        _confirm(hit.loop);
        return;
      }
    }

    notifyListeners();
  }

  void onPanEnd() {
    if (_status != GameStatus.drawing) return;
    // 交差せず指を離した → 不成立（spec §6.2）。
    _fail(FailReason.notClosed);
  }

  void _fail(FailReason reason) {
    _failReason = reason;
    _status = GameStatus.fail;
    notifyListeners();
  }

  Future<void> _confirm(List<Offset> loop) async {
    final c = _composite!;

    // 切り取るのは「顔（中心）を含まない側」＝なぞりで切り離した外側の襟。
    // ループが顔の中心を内側に含む場合は、捕捉領域はその補集合になる。
    final faceCenter = c.lizardRect.center;
    final faceInsideLoop = pointInPolygon(faceCenter, loop);
    final insideCaptured = c.eriMask.countOpaqueInside(loop);
    final captured = faceInsideLoop
        ? (c.eriMask.totalOpaque - insideCaptured)
        : insideCaptured;

    // スコア計算（ローカル座標, spec §6.4）。
    final score = _scoreCalculator.compute(
      capturedPixels: captured,
      totalPixels: c.eriMask.totalOpaque,
    );

    // 切り取り画像生成（捕捉した側だけを残す, spec §6.5）。
    final cutout = await CutoutRenderer.render(
      composite: c,
      loop: loop,
      keepInside: !faceInsideLoop,
    );

    _result = GameResult(
      score: score,
      cutoutImage: cutout.image,
      cutoutPng: cutout.png,
      loop: loop,
    );
    _status = GameStatus.success;
    notifyListeners();
  }

  void reset() {
    _stroke.clear();
    _status = _composite == null ? GameStatus.loading : GameStatus.ready;
    _failReason = FailReason.none;
    _failLocalPoint = null;
    _result = null;
    notifyListeners();
  }
}
