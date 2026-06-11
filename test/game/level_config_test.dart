import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_example_app/screens/game/level_config.dart';

void main() {
  test('LevelConfig.fromJson reads display settings from json', () {
    final config = LevelConfig.fromJson({
      'levelId': 9,
      'closeThresholdFactor': 0.1,
      'lizardBody': {
        'center': {'x': 0.5, 'y': 0.55},
        'radiusFactor': 0.12,
      },
      'frillCircle': {
        'center': {'x': 0.5, 'y': 0.52},
        'radiusFactor': 0.22,
      },
      'shadowEllipse': {
        'center': {'x': 0.5, 'y': 0.72},
        'radiusXFactor': 0.22,
        'radiusYFactor': 0.05,
      },
      'ngCircles': [],
      'ngRects': [],
      'swayAmplitudeFactor': 0.05,
      'minPoints': 6,
      'minPathLengthFactor': 0.2,
      'minAreaFactor': 0.001,
      'minIntersectionGap': 4,
      'faceScale': 1.35,
      'frillDisplayScale': 1.15,
      'faceOffset': {'x': 0.01, 'y': -0.02},
    });

    expect(config.faceScale, 1.35);
    expect(config.frillDisplayScale, 1.15);
    expect(config.faceOffset, const Offset(0.01, -0.02));
  });
}
