import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'sprite_transform.dart';

/// ゲーム画面の描画（spec §6 / §8.2）。
///
/// スプライト（本体・襟）と、なぞり線をすべて `spriteTransform` 配下で描く。
/// → なぞり線は襟と一緒に回る（ローカル座標固定, spec §8.2）。
class GamePainter extends CustomPainter {
  GamePainter({
    required this.eriImage,
    required this.lizardImage,
    required this.eriRect,
    required this.lizardRect,
    required this.transform,
    required this.strokeLocalPoints,
    required this.glowColor,
  });

  final ui.Image eriImage;
  final ui.Image lizardImage;
  final Rect eriRect;
  final Rect lizardRect;
  final SpriteTransform transform;
  final List<Offset> strokeLocalPoints;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.transform(transform.matrix.storage);

    final imgPaint = Paint()..filterQuality = FilterQuality.high;
    // 襟 → 本体（顔）の順で重ねる。
    canvas.drawImageRect(
      eriImage,
      Rect.fromLTWH(0, 0, eriImage.width.toDouble(), eriImage.height.toDouble()),
      eriRect,
      imgPaint,
    );
    canvas.drawImageRect(
      lizardImage,
      Rect.fromLTWH(
        0,
        0,
        lizardImage.width.toDouble(),
        lizardImage.height.toDouble(),
      ),
      lizardRect,
      imgPaint,
    );

    // なぞり線（発光）。ローカル座標で描くため回転に追従する。
    if (strokeLocalPoints.length >= 2) {
      final path = Path()..addPolygon(strokeLocalPoints, false);
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = glowColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(path, glow);

      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white;
      canvas.drawPath(path, line);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GamePainter old) => true;
}
