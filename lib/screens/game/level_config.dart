import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

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
    required this.faceScale,
    required this.frillDisplayScale,
    required this.faceOffset,
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
  final double faceScale;
  final double frillDisplayScale;
  final Offset faceOffset;

  static const String assetPath = 'assets/game/level.json';
  static const int maxLevel = 3;
  static Map<int, LevelConfig> _configs = _defaultConfigs;

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
    return ngRects.map((rect) => rect.toRect(size).shift(swayOffset)).toList();
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

  Offset resolvedFaceCenter(Size size, Offset swayOffset) {
    final frillCenter = resolvedFrill(size, swayOffset).center;
    final base = min(size.width, size.height);
    return frillCenter + Offset(faceOffset.dx * base, faceOffset.dy * base);
  }

  static LevelConfig forLevel(int levelId) {
    return _configs[levelId] ?? _configs[1]!;
  }

  static Future<void> loadFromAsset([String path = assetPath]) async {
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid level config root: $path');
    }
    final levels = decoded['levels'];
    if (levels is! List) {
      throw FormatException('Missing levels array: $path');
    }

    final configs = <int, LevelConfig>{};
    for (final entry in levels) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Each level entry must be an object');
      }
      final config = LevelConfig.fromJson(entry);
      configs[config.levelId] = config;
    }
    if (configs.isEmpty) {
      throw FormatException('No level configs found: $path');
    }
    _configs = configs;
  }

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    return LevelConfig(
      levelId: _readInt(json, 'levelId'),
      closeThresholdFactor: _readDouble(json, 'closeThresholdFactor'),
      lizardBody: NormalizedCircle.fromJson(_readMap(json, 'lizardBody')),
      frillCircle: NormalizedCircle.fromJson(_readMap(json, 'frillCircle')),
      shadowEllipse: NormalizedEllipse.fromJson(
        _readMap(json, 'shadowEllipse'),
      ),
      ngCircles: _readList(
        json,
        'ngCircles',
      ).map((item) => NormalizedCircle.fromJson(_castMap(item))).toList(),
      ngRects: _readList(
        json,
        'ngRects',
      ).map((item) => NormalizedRect.fromJson(_castMap(item))).toList(),
      swayAmplitudeFactor: _readDouble(json, 'swayAmplitudeFactor'),
      minPoints: _readInt(json, 'minPoints'),
      minPathLengthFactor: _readDouble(json, 'minPathLengthFactor'),
      minAreaFactor: _readDouble(json, 'minAreaFactor'),
      minIntersectionGap: _readInt(json, 'minIntersectionGap'),
      faceScale: _readDouble(json, 'faceScale'),
      frillDisplayScale: _readDouble(json, 'frillDisplayScale'),
      faceOffset: _readOffset(json, 'faceOffset'),
    );
  }

  static const Map<int, LevelConfig> _defaultConfigs = {
    1: LevelConfig(
      levelId: 1,
      closeThresholdFactor: 0.08,
      lizardBody: NormalizedCircle(
        center: Offset(0.5, 0.55),
        radiusFactor: 0.12,
      ),
      frillCircle: NormalizedCircle(
        center: Offset(0.5, 0.52),
        radiusFactor: 0.22,
      ),
      shadowEllipse: NormalizedEllipse(
        center: Offset(0.5, 0.72),
        radiusXFactor: 0.22,
        radiusYFactor: 0.05,
      ),
      ngCircles: [],
      ngRects: [],
      swayAmplitudeFactor: 0.0,
      minPoints: 6,
      minPathLengthFactor: 0.2,
      minAreaFactor: 0.001,
      minIntersectionGap: 4,
      faceScale: 1.2,
      frillDisplayScale: 1.1,
      faceOffset: Offset.zero,
    ),
    2: LevelConfig(
      levelId: 2,
      closeThresholdFactor: 0.08,
      lizardBody: NormalizedCircle(
        center: Offset(0.5, 0.55),
        radiusFactor: 0.12,
      ),
      frillCircle: NormalizedCircle(
        center: Offset(0.5, 0.52),
        radiusFactor: 0.22,
      ),
      shadowEllipse: NormalizedEllipse(
        center: Offset(0.5, 0.72),
        radiusXFactor: 0.22,
        radiusYFactor: 0.05,
      ),
      ngCircles: [],
      ngRects: [],
      swayAmplitudeFactor: 0.0,
      minPoints: 6,
      minPathLengthFactor: 0.2,
      minAreaFactor: 0.001,
      minIntersectionGap: 4,
      faceScale: 1.2,
      frillDisplayScale: 1.1,
      faceOffset: Offset.zero,
    ),
    3: LevelConfig(
      levelId: 3,
      closeThresholdFactor: 0.08,
      lizardBody: NormalizedCircle(
        center: Offset(0.5, 0.55),
        radiusFactor: 0.12,
      ),
      frillCircle: NormalizedCircle(
        center: Offset(0.5, 0.52),
        radiusFactor: 0.22,
      ),
      shadowEllipse: NormalizedEllipse(
        center: Offset(0.5, 0.72),
        radiusXFactor: 0.22,
        radiusYFactor: 0.05,
      ),
      ngCircles: [],
      ngRects: [],
      swayAmplitudeFactor: 0.05,
      minPoints: 6,
      minPathLengthFactor: 0.2,
      minAreaFactor: 0.001,
      minIntersectionGap: 4,
      faceScale: 1.2,
      frillDisplayScale: 1.1,
      faceOffset: Offset.zero,
    ),
  };
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

  EllipseArea shift(Offset delta) =>
      EllipseArea(center: center + delta, radiusX: radiusX, radiusY: radiusY);
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

  factory NormalizedCircle.fromJson(Map<String, dynamic> json) {
    return NormalizedCircle(
      center: _readOffset(json, 'center'),
      radiusFactor: _readDouble(json, 'radiusFactor'),
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

  factory NormalizedEllipse.fromJson(Map<String, dynamic> json) {
    return NormalizedEllipse(
      center: _readOffset(json, 'center'),
      radiusXFactor: _readDouble(json, 'radiusXFactor'),
      radiusYFactor: _readDouble(json, 'radiusYFactor'),
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

  factory NormalizedRect.fromJson(Map<String, dynamic> json) {
    return NormalizedRect(
      left: _readDouble(json, 'left'),
      top: _readDouble(json, 'top'),
      width: _readDouble(json, 'width'),
      height: _readDouble(json, 'height'),
    );
  }
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  return _castMap(json[key]);
}

Map<String, dynamic> _castMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  throw FormatException('Expected object but got $value');
}

List<dynamic> _readList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is List) {
    return value;
  }
  throw FormatException('Expected list for $key but got $value');
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Expected int for $key but got $value');
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('Expected number for $key but got $value');
}

Offset _readOffset(Map<String, dynamic> json, String key) {
  final map = _readMap(json, key);
  return Offset(_readDouble(map, 'x'), _readDouble(map, 'y'));
}
