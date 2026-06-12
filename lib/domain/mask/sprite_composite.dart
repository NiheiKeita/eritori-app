import 'dart:typed_data';
import 'dart:ui' as ui;

import '../config/game_config.dart';
import 'pixel_mask.dart';

/// トカゲ本体（顔）と襟を、共通の**ローカル座標空間**に配置した合成スプライト。
///
/// 襟マスク・本体マスクの両方を同一の座標系・同一寸法で保持するため、
/// `isOpaqueAt(local)` がどちらも自明に引ける（spec §6.1 / §6.3）。
/// 判定・スコア計算はこのローカル座標空間で行い、回転は描画時の変換行列で吸収する。
class SpriteComposite {
  SpriteComposite({
    required this.localWidth,
    required this.localHeight,
    required this.eriMask,
    required this.lizardMask,
    required this.eriImage,
    required this.lizardImage,
    required this.eriRect,
    required this.lizardRect,
  });

  /// ローカル座標空間の寸法（マスク・判定の基準）。
  final int localWidth;
  final int localHeight;

  /// 襟マスク（スコア対象）。本体マスク（失敗判定）。共にローカル座標空間。
  final PixelMask eriMask;
  final PixelMask lizardMask;

  /// 描画用の元画像と、ローカル座標空間における配置矩形。
  final ui.Image eriImage;
  final ui.Image lizardImage;
  final ui.Rect eriRect;
  final ui.Rect lizardRect;

  /// 襟画像と本体画像から合成スプライトを構築する。
  ///
  /// [faceScale] は襟ローカル幅に対する顔の幅比、[faceOffset] はローカル空間
  /// 中央からの正規化オフセット（顔の配置, plan.md の仮定）。
  static Future<SpriteComposite> build({
    required ui.Image eriImage,
    required ui.Image lizardImage,
    double faceScale = 0.5,
    ui.Offset faceOffset = const ui.Offset(0, -0.05),
    int longEdge = GameConfig.maskLongEdge,
  }) async {
    // ローカル空間は襟のアスペクトを長辺 longEdge に合わせて定義する。
    final eriW = eriImage.width;
    final eriH = eriImage.height;
    final scale = longEdge / (eriW > eriH ? eriW : eriH);
    final localW = (eriW * scale).round();
    final localH = (eriH * scale).round();

    final eriRect = ui.Rect.fromLTWH(0, 0, localW.toDouble(), localH.toDouble());

    // 顔の配置矩形（襟ローカル空間内）。
    final faceW = localW * faceScale;
    final faceAspect = lizardImage.height / lizardImage.width;
    final faceH = faceW * faceAspect;
    final center = ui.Offset(
      localW / 2 + faceOffset.dx * localW,
      localH / 2 + faceOffset.dy * localH,
    );
    final lizardRect = ui.Rect.fromCenter(
      center: center,
      width: faceW,
      height: faceH,
    );

    final eriAlpha =
        await _rasterizeAlpha(eriImage, eriRect, localW, localH);
    final lizardAlpha =
        await _rasterizeAlpha(lizardImage, lizardRect, localW, localH);

    return SpriteComposite(
      localWidth: localW,
      localHeight: localH,
      eriMask: PixelMask.fromAlpha(localW, localH, eriAlpha),
      lizardMask: PixelMask.fromAlpha(localW, localH, lizardAlpha),
      eriImage: eriImage,
      lizardImage: lizardImage,
      eriRect: eriRect,
      lizardRect: lizardRect,
    );
  }

  /// [image] を [dstRect] に描いた canvasW×canvasH の透明キャンバスから
  /// アルファchのみを抽出する。
  static Future<Uint8List> _rasterizeAlpha(
    ui.Image image,
    ui.Rect dstRect,
    int canvasW,
    int canvasH,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      ),
      dstRect,
      paint,
    );
    final picture = recorder.endRecording();
    final raster = await picture.toImage(canvasW, canvasH);
    final byteData =
        await raster.toByteData(format: ui.ImageByteFormat.rawRgba);
    picture.dispose();
    raster.dispose();

    final rgba = byteData!.buffer.asUint8List();
    final alpha = Uint8List(canvasW * canvasH);
    for (var i = 0; i < canvasW * canvasH; i++) {
      alpha[i] = rgba[i * 4 + 3];
    }
    return alpha;
  }
}
