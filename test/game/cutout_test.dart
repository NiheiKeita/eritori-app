import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_example_app/screens/game/cutout.dart';

void main() {
  test(
    'calculateOpaqueCutoutArea counts only opaque pixels inside polygon',
    () async {
      final area = await calculateOpaqueCutoutArea(
        points: const [Offset(0, 0), Offset(4, 0), Offset(4, 4), Offset(0, 4)],
        centerPoint: const Offset(10, 10),
        size: const Size(4, 4),
        opaquePointTester: (point, _) => point.dx < 2,
      );

      expect(area, 8);
    },
  );

  test(
    'calculateOpaqueCutoutArea excludes polygon when center is inside',
    () async {
      final area = await calculateOpaqueCutoutArea(
        points: const [Offset(1, 1), Offset(3, 1), Offset(3, 3), Offset(1, 3)],
        centerPoint: const Offset(2, 2),
        size: const Size(4, 4),
        opaquePointTester: (_, __) => true,
      );

      expect(area, 12);
    },
  );
}
