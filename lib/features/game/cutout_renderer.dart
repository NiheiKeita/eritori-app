import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show Offset;

import '../../domain/config/game_config.dart';
import '../../domain/mask/sprite_composite.dart';
import '../../domain/scoring/polygon_math.dart';

/// 切り取り画像の生成結果。
class CutoutResult {
  CutoutResult({required this.image, required this.png});

  final ui.Image image;
  final Uint8List png;
}

/// 確定したループ多角形で襟領域を切り出して PNG 化する（spec §6.5）。
///
/// ループ多角形（ローカル座標）を Path にして clipPath → 襟スプライト描画。
/// 透過背景で「スパッと切れた」断面を残し、長辺を保存用解像度にスケールする。
class CutoutRenderer {
  CutoutRenderer._();

  /// [keepInside] が true ならループ内側を、false ならループ外側（顔を含まない
  /// 切り離した襟＝補集合）を残す。
  static Future<CutoutResult> render({
    required SpriteComposite composite,
    required List<Offset> loop,
    bool keepInside = true,
    int longEdge = GameConfig.savedImageLongEdge,
  }) async {
    final localW = composite.localWidth.toDouble();
    final localH = composite.localHeight.toDouble();

    // クロップ範囲: 内側はループのbboxで詰める。外側（補集合）はスプライト全体。
    final ui.Rect crop;
    if (keepInside) {
      final box = boundingBox(loop);
      final l = box.left.clamp(0.0, localW);
      final t = box.top.clamp(0.0, localH);
      final w = (box.right.clamp(0.0, localW) - l).clamp(1.0, localW);
      final h = (box.bottom.clamp(0.0, localH) - t).clamp(1.0, localH);
      crop = ui.Rect.fromLTWH(l, t, w, h);
    } else {
      crop = ui.Rect.fromLTWH(0, 0, localW, localH);
    }

    final scale = longEdge / (crop.width > crop.height ? crop.width : crop.height);
    final outW = (crop.width * scale).round().clamp(1, longEdge);
    final outH = (crop.height * scale).round().clamp(1, longEdge);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // クロップ原点を詰めつつ保存解像度へスケール。
    canvas.scale(scale, scale);
    canvas.translate(-crop.left, -crop.top);

    // 捕捉した側でクリップ（アンチエイリアスで滑らかな断面に）。
    final ui.Path path;
    if (keepInside) {
      path = ui.Path()..addPolygon(loop, true);
    } else {
      // 補集合: スプライト全体の矩形からループを差し引く（evenOdd）。
      path = ui.Path()
        ..fillType = ui.PathFillType.evenOdd
        ..addRect(ui.Rect.fromLTWH(0, 0, localW, localH))
        ..addPolygon(loop, true);
    }
    canvas.clipPath(path, doAntiAlias: true);

    // 襟スプライトをローカル空間の配置矩形に描画。
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.high;
    canvas.drawImageRect(
      composite.eriImage,
      ui.Rect.fromLTWH(
        0,
        0,
        composite.eriImage.width.toDouble(),
        composite.eriImage.height.toDouble(),
      ),
      composite.eriRect,
      paint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(outW, outH);
    picture.dispose();

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return CutoutResult(image: image, png: byteData!.buffer.asUint8List());
  }
}
