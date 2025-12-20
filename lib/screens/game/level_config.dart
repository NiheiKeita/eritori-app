import 'dart:math';

import 'package:flutter/material.dart';

class LevelConfig {
  const LevelConfig({
    required this.levelId,
    required this.closeThresholdFactor,
    required this.lizardBody,
    required this.frillCircle,
    required this.shadowEllipse,
    required this.ngCircles,
    required this.ngRects,
    required this.swayAmplitudeFactor,
    required this.minPoints,
    required this.minPathLengthFactor,
    required this.minAreaFactor,
    required this.minIntersectionGap,
  });

  final int levelId;
  final double closeThresholdFactor;
  final NormalizedCircle lizardBody;
  final NormalizedCircle frillCircle;
  final NormalizedEllipse shadowEllipse;
  final List<NormalizedCircle> ngCircles;
  final List<NormalizedRect> ngRects;
  final double swayAmplitudeFactor;
  final int minPoints;
  final double minPathLengthFactor;
  final double minAreaFactor;
  final int minIntersectionGap;

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

  CircleArea resolvedBody(Size size, Offset swayOffset) {
    return lizardBody.toCircle(size).shift(swayOffset);
  }

  CircleArea resolvedFrill(Size size, Offset swayOffset) {
    return frillCircle.toCircle(size).shift(swayOffset);
  }

  EllipseArea resolvedShadow(Size size, Offset swayOffset) {
    return shadowEllipse.toEllipse(size).shift(swayOffset);
  }

  static const int maxLevel = 3;

  static LevelConfig forLevel(int levelId) {
    switch (levelId) {
      case 2:
        return LevelConfig(
          levelId: 2,
          closeThresholdFactor: 0.08,
          lizardBody: const NormalizedCircle(
            center: Offset(0.5, 0.55),
            radiusFactor: 0.12,
          ),
          frillCircle: const NormalizedCircle(
            center: Offset(0.5, 0.52),
            radiusFactor: 0.22,
          ),
          shadowEllipse: const NormalizedEllipse(
            center: Offset(0.5, 0.72),
            radiusXFactor: 0.22,
            radiusYFactor: 0.05,
          ),
          ngCircles: const [],
          ngRects: const [],
          swayAmplitudeFactor: 0.04,
          minPoints: 6,
          minPathLengthFactor: 0.2,
          minAreaFactor: 0.001,
          minIntersectionGap: 4,
        );
      case 3:
        return LevelConfig(
          levelId: 3,
          closeThresholdFactor: 0.08,
          lizardBody: const NormalizedCircle(
            center: Offset(0.5, 0.55),
            radiusFactor: 0.12,
          ),
          frillCircle: const NormalizedCircle(
            center: Offset(0.5, 0.52),
            radiusFactor: 0.22,
          ),
          shadowEllipse: const NormalizedEllipse(
            center: Offset(0.5, 0.72),
            radiusXFactor: 0.22,
            radiusYFactor: 0.05,
          ),
          ngCircles: const [],
          ngRects: const [],
          swayAmplitudeFactor: 0.05,
          minPoints: 6,
          minPathLengthFactor: 0.2,
          minAreaFactor: 0.001,
          minIntersectionGap: 4,
        );
      case 1:
      default:
        return LevelConfig(
          levelId: 1,
          closeThresholdFactor: 0.08,
          lizardBody: const NormalizedCircle(
            center: Offset(0.5, 0.55),
            radiusFactor: 0.12,
          ),
          frillCircle: const NormalizedCircle(
            center: Offset(0.5, 0.52),
            radiusFactor: 0.22,
          ),
          shadowEllipse: const NormalizedEllipse(
            center: Offset(0.5, 0.72),
            radiusXFactor: 0.22,
            radiusYFactor: 0.05,
          ),
          ngCircles: const [],
          ngRects: const [],
          swayAmplitudeFactor: 0.0,
          minPoints: 6,
          minPathLengthFactor: 0.2,
          minAreaFactor: 0.001,
          minIntersectionGap: 4,
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

class EllipseArea {
  const EllipseArea({
    required this.center,
    required this.radiusX,
    required this.radiusY,
  });

  final Offset center;
  final double radiusX;
  final double radiusY;

  EllipseArea shift(Offset delta) => EllipseArea(
        center: center + delta,
        radiusX: radiusX,
        radiusY: radiusY,
      );
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

class NormalizedEllipse {
  const NormalizedEllipse({
    required this.center,
    required this.radiusXFactor,
    required this.radiusYFactor,
  });

  final Offset center;
  final double radiusXFactor;
  final double radiusYFactor;

  EllipseArea toEllipse(Size size) {
    return EllipseArea(
      center: Offset(center.dx * size.width, center.dy * size.height),
      radiusX: radiusXFactor * size.width,
      radiusY: radiusYFactor * size.height,
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
