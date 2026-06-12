import 'package:flutter/widgets.dart';

/// 襟スプライトのローカル座標 ⇄ 画面座標を結ぶ変換（spec §6.1）。
///
/// スプライトはキャンバス中央に配置し、`fitFraction` 分のスペースに収まるよう
/// 等倍スケールし、中心まわりに [rotationRadians] 回転する。
/// 判定は常にローカル座標で行い、[toLocal] が画面座標を逆行列で写す。
class SpriteTransform {
  SpriteTransform._(this.matrix, this._inverse, this.scale);

  /// ローカル → 画面 の変換行列。
  final Matrix4 matrix;
  final Matrix4 _inverse;

  /// ローカル→画面の等倍スケール（画面px = ローカル単位 * scale）。
  final double scale;

  factory SpriteTransform.fit({
    required Size canvasSize,
    required int localWidth,
    required int localHeight,
    double rotationRadians = 0,
    double fitFraction = 0.8,
  }) {
    final scaleX = canvasSize.width * fitFraction / localWidth;
    final scaleY = canvasSize.height * fitFraction / localHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final m = Matrix4.identity()
      ..translateByDouble(canvasSize.width / 2, canvasSize.height / 2, 0, 1)
      ..rotateZ(rotationRadians)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-localWidth / 2, -localHeight / 2, 0, 1);

    final inv = Matrix4.inverted(m);
    return SpriteTransform._(m, inv, scale);
  }

  /// 画面座標をローカル座標へ写す。
  Offset toLocal(Offset screenPoint) =>
      MatrixUtils.transformPoint(_inverse, screenPoint);

  /// ローカル座標を画面座標へ写す（なぞり線の描画用）。
  Offset toScreen(Offset localPoint) =>
      MatrixUtils.transformPoint(matrix, localPoint);
}
