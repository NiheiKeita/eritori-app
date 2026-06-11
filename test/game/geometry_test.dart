import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_example_app/screens/game/geometry.dart';

void main() {
  test('polygonArea calculates square area', () {
    final points = [
      const Offset(0, 0),
      const Offset(10, 0),
      const Offset(10, 10),
      const Offset(0, 10),
    ];
    expect(polygonArea(points), 100);
  });

  test('lineIntersectsCircle detects intersection', () {
    final hit = lineIntersectsCircle(
      const Offset(0, 0),
      const Offset(10, 0),
      const Offset(5, 0),
      2,
    );
    expect(hit, isTrue);

    final miss = lineIntersectsCircle(
      const Offset(0, 0),
      const Offset(10, 0),
      const Offset(5, 5),
      2,
    );
    expect(miss, isFalse);
  });

  test('lineIntersectsEllipse detects intersection', () {
    final hit = lineIntersectsEllipse(
      const Offset(0, 0),
      const Offset(10, 0),
      const Offset(5, 0),
      4,
      2,
    );
    expect(hit, isTrue);

    final miss = lineIntersectsEllipse(
      const Offset(0, 0),
      const Offset(10, 0),
      const Offset(5, 5),
      4,
      2,
    );
    expect(miss, isFalse);
  });
}
