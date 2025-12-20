import 'dart:math';

import 'package:flutter/material.dart';

class LevelConfig {
  const LevelConfig({
    required this.levelId,
    required this.closeThresholdFactor,
    required this.ngCircles,
    required this.ngRects,
    required this.swayAmplitudeFactor,
    required this.minPoints,
    required this.minPathLengthFactor,
    required this.minAreaFactor,
  });

  final int levelId;
  final double closeThresholdFactor;
  final List<NormalizedCircle> ngCircles;
  final List<NormalizedRect> ngRects;
  final double swayAmplitudeFactor;
  final int minPoints;
  final double minPathLengthFactor;
  final double minAreaFactor;

  double closeThreshold(Size size) =>
      closeThresholdFactor * min(size.width, size.height);

  double minPathLength(Size size) =>
      minPathLengthFactor * min(size.width, size.height);

  double minArea(Size size) => minAreaFactor * size.width * size.height;

  Offset swayOffset(Size size, double animationValue) {
    if (swayAmplitudeFactor <= 0) {
      return Offset.zero;
    }
    final amplitude = swayAmplitudeFactor * size.width;
    return Offset(amplitude * sin(animationValue * 2 * pi), 0);
  }

  List<CircleArea> resolvedCircles(Size size, Offset swayOffset) {
    return ngCircles
        .map((circle) => circle.toCircle(size).shift(swayOffset))
        .toList();
  }

  List<Rect> resolvedRects(Size size, Offset swayOffset) {
    return ngRects
        .map((rect) => rect.toRect(size).shift(swayOffset))
        .toList();
  }

  static const int maxLevel = 3;

  static LevelConfig forLevel(int levelId) {
    switch (levelId) {
      case 2:
        return LevelConfig(
          levelId: 2,
          closeThresholdFactor: 0.08,
          ngCircles: const [
            NormalizedCircle(center: Offset(0.5, 0.34), radiusFactor: 0.14),
          ],
          ngRects: const [
            NormalizedRect(
              left: 0.17,
              top: 0.23,
              width: 0.12,
              height: 0.12,
            ),
            NormalizedRect(
              left: 0.71,
              top: 0.23,
              width: 0.12,
              height: 0.12,
            ),
          ],
          swayAmplitudeFactor: 0.04,
          minPoints: 6,
          minPathLengthFactor: 0.12,
          minAreaFactor: 0.001,
        );
      case 3:
        return LevelConfig(
          levelId: 3,
          closeThresholdFactor: 0.08,
          ngCircles: const [
            NormalizedCircle(center: Offset(0.5, 0.34), radiusFactor: 0.14),
          ],
          ngRects: const [
            NormalizedRect(
              left: 0.17,
              top: 0.23,
              width: 0.12,
              height: 0.12,
            ),
            NormalizedRect(
              left: 0.71,
              top: 0.23,
              width: 0.12,
              height: 0.12,
            ),
          ],
          swayAmplitudeFactor: 0.05,
          minPoints: 6,
          minPathLengthFactor: 0.12,
          minAreaFactor: 0.001,
        );
      case 1:
      default:
        return LevelConfig(
          levelId: 1,
          closeThresholdFactor: 0.08,
          ngCircles: const [
            NormalizedCircle(center: Offset(0.5, 0.34), radiusFactor: 0.14),
          ],
          ngRects: const [
            NormalizedRect(
              left: 0.17,
              top: 0.23,
              width: 0.12,
              height: 0.12,
            ),
            NormalizedRect(
              left: 0.71,
              top: 0.23,
              width: 0.12,
              height: 0.12,
            ),
          ],
          swayAmplitudeFactor: 0.0,
          minPoints: 6,
          minPathLengthFactor: 0.12,
          minAreaFactor: 0.001,
        );
    }
  }
}

class CircleArea {
  const CircleArea({required this.center, required this.radius});

  final Offset center;
  final double radius;

  CircleArea shift(Offset delta) =>
      CircleArea(center: center + delta, radius: radius);
}

class NormalizedCircle {
  const NormalizedCircle({required this.center, required this.radiusFactor});

  final Offset center;
  final double radiusFactor;

  CircleArea toCircle(Size size) {
    final radius = radiusFactor * min(size.width, size.height);
    return CircleArea(
      center: Offset(center.dx * size.width, center.dy * size.height),
      radius: radius,
    );
  }
}

class NormalizedRect {
  const NormalizedRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  Rect toRect(Size size) {
    return Rect.fromLTWH(
      left * size.width,
      top * size.height,
      width * size.width,
      height * size.height,
    );
  }
}
