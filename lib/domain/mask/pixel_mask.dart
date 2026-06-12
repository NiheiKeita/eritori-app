import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show Offset;

import '../config/game_config.dart';
import '../scoring/polygon_math.dart';

/// PNG のアルファchから生成する当たり判定マスク（spec §6.3 / §6.4）。
///
/// マスクは「スプライトのローカル座標 = マスクピクセル座標」として扱う。
/// 起動時に縮小したアルファバッファを保持し、[isOpaqueAt] を O(1) で判定する。
/// 回転レベルでもローカル座標で本体は静止しているため、マスクは1枚で済む。
class PixelMask {
  PixelMask._(this.width, this.height, this._alpha, this.totalOpaque);

  /// マスクの幅・高さ（マスクピクセル単位 = ローカル座標の範囲）。
  final int width;
  final int height;

  /// 1ピクセル1バイトのアルファ値（0..255）。長さ = width*height。
  final Uint8List _alpha;

  /// 非透過ピクセル総数（事前計算, スコア分母 totalEriPixels に使用）。
  final int totalOpaque;

  static int get _threshold => (GameConfig.opaqueAlphaThreshold * 255).round();

  /// ローカル座標 ([x],[y]) が非透過（本体/襟）か。範囲外は透過扱い。
  bool isOpaqueAt(double x, double y) {
    final ix = x.floor();
    final iy = y.floor();
    if (ix < 0 || iy < 0 || ix >= width || iy >= height) return false;
    return _alpha[iy * width + ix] > _threshold;
  }

  /// ループ多角形 [polygon]（ローカル座標）の内側にある非透過ピクセル数を数える。
  /// バウンディングボックス内のみ走査（spec §6.4 メモ）。
  int countOpaqueInside(List<Offset> polygon) {
    if (polygon.length < 3) return 0;
    final box = boundingBox(polygon);
    final x0 = box.left.floor().clamp(0, width - 1);
    final y0 = box.top.floor().clamp(0, height - 1);
    final x1 = box.right.ceil().clamp(0, width - 1);
    final y1 = box.bottom.ceil().clamp(0, height - 1);
    var count = 0;
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        if (_alpha[y * width + x] <= _threshold) continue;
        // ピクセル中心で内外判定。
        if (pointInPolygon(Offset(x + 0.5, y + 0.5), polygon)) count++;
      }
    }
    return count;
  }

  /// 既に抽出済みのアルファバッファからマスクを構築する。
  /// [alpha] は長さ width*height、各バイトがアルファ値(0..255)。
  factory PixelMask.fromAlpha(int width, int height, Uint8List alpha) {
    final threshold = _threshold;
    var opaque = 0;
    for (var i = 0; i < alpha.length; i++) {
      if (alpha[i] > threshold) opaque++;
    }
    return PixelMask._(width, height, alpha, opaque);
  }

  /// [image] を長辺 [longEdge] に縮小してアルファマスクを生成する。
  static Future<PixelMask> fromImage(
    ui.Image image, {
    int longEdge = GameConfig.maskLongEdge,
  }) async {
    final srcW = image.width;
    final srcH = image.height;
    final scale = longEdge / (srcW > srcH ? srcW : srcH);
    final dstW = (srcW * scale).round().clamp(1, longEdge);
    final dstH = (srcH * scale).round().clamp(1, longEdge);

    // 縮小描画してピクセルを取得。
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, srcW.toDouble(), srcH.toDouble()),
      ui.Rect.fromLTWH(0, 0, dstW.toDouble(), dstH.toDouble()),
      paint,
    );
    final picture = recorder.endRecording();
    final scaled = await picture.toImage(dstW, dstH);
    final byteData =
        await scaled.toByteData(format: ui.ImageByteFormat.rawRgba);
    picture.dispose();
    scaled.dispose();

    final rgba = byteData!.buffer.asUint8List();
    final alpha = Uint8List(dstW * dstH);
    var opaque = 0;
    final threshold = _threshold;
    for (var i = 0; i < dstW * dstH; i++) {
      final a = rgba[i * 4 + 3];
      alpha[i] = a;
      if (a > threshold) opaque++;
    }
    return PixelMask._(dstW, dstH, alpha, opaque);
  }
}
