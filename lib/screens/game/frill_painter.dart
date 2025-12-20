import 'dart:math';

import 'package:flutter/material.dart';

import 'game_controller.dart';
import 'level_config.dart';

class FrillPainter extends CustomPainter {
  FrillPainter({
    required this.points,
    required this.status,
    required this.config,
    required this.swayOffset,
  });

  final List<Offset> points;
  final GameStatus status;
  final LevelConfig config;
  final Offset swayOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.55) + swayOffset;
    final faceRadius = min(size.width, size.height) * 0.16;
    final frillRadius = min(size.width, size.height) * 0.32;

    final facePaint = Paint()
      ..color = const Color(0xFFF4C27E)
      ..style = PaintingStyle.fill;
    final frillPaint = Paint()
      ..color = const Color(0xFFFFD36C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    final earPaint = Paint()
      ..color = const Color(0xFFF2B26F)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, frillRadius, frillPaint);
    canvas.drawCircle(center, faceRadius, facePaint);

    final earSize = Size(size.width * 0.12, size.height * 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - faceRadius * 1.2, center.dy - faceRadius),
          width: earSize.width,
          height: earSize.height,
        ),
        const Radius.circular(6),
      ),
      earPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + faceRadius * 1.2, center.dy - faceRadius),
          width: earSize.width,
          height: earSize.height,
        ),
        const Radius.circular(6),
      ),
      earPaint,
    );

    final pathPaint = Paint()
      ..color = status == GameStatus.failed
          ? Colors.redAccent
          : const Color(0xFF3D7C6D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, pathPaint);
    }

    if (status == GameStatus.success) {
      final highlightPaint = Paint()
        ..color = const Color(0xFF65C3A3).withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, frillRadius * 0.9, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FrillPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.status != status ||
        oldDelegate.swayOffset != swayOffset ||
        oldDelegate.config.levelId != config.levelId;
  }
}
