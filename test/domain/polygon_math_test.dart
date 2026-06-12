import 'package:flutter_example_app/domain/scoring/polygon_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('segmentsIntersect', () {
    test('crossing segments intersect', () {
      expect(
        segmentsIntersect(
          const Offset(0, 0),
          const Offset(10, 10),
          const Offset(0, 10),
          const Offset(10, 0),
        ),
        isTrue,
      );
    });

    test('parallel segments do not intersect', () {
      expect(
        segmentsIntersect(
          const Offset(0, 0),
          const Offset(10, 0),
          const Offset(0, 5),
          const Offset(10, 5),
        ),
        isFalse,
      );
    });
  });

  group('properSegmentsIntersect (strict)', () {
    test('true for a clean interior cross', () {
      expect(
        properSegmentsIntersect(
          const Offset(0, 0),
          const Offset(10, 10),
          const Offset(0, 10),
          const Offset(10, 0),
        ),
        isTrue,
      );
    });

    test('false for endpoint touch (T-junction)', () {
      // (5,0) は水平線分上にあるが端点接触 → 厳密交差ではない。
      expect(
        properSegmentsIntersect(
          const Offset(5, 10),
          const Offset(5, 0),
          const Offset(0, 0),
          const Offset(10, 0),
        ),
        isFalse,
      );
    });

    test('false for collinear overlap', () {
      expect(
        properSegmentsIntersect(
          const Offset(0, 0),
          const Offset(10, 0),
          const Offset(5, 0),
          const Offset(15, 0),
        ),
        isFalse,
      );
    });
  });

  group('segmentIntersectionPoint', () {
    test('returns midpoint crossing', () {
      final p = segmentIntersectionPoint(
        const Offset(0, 0),
        const Offset(10, 10),
        const Offset(0, 10),
        const Offset(10, 0),
      );
      expect(p, isNotNull);
      expect(p!.dx, closeTo(5, 1e-9));
      expect(p.dy, closeTo(5, 1e-9));
    });

    test('returns null when parallel', () {
      expect(
        segmentIntersectionPoint(
          const Offset(0, 0),
          const Offset(10, 0),
          const Offset(0, 5),
          const Offset(10, 5),
        ),
        isNull,
      );
    });
  });

  group('polygonArea', () {
    test('unit square area is 1', () {
      expect(
        polygonArea(const [
          Offset(0, 0),
          Offset(1, 0),
          Offset(1, 1),
          Offset(0, 1),
        ]),
        closeTo(1, 1e-9),
      );
    });

    test('degenerate polygon area is 0', () {
      expect(polygonArea(const [Offset(0, 0), Offset(1, 1)]), 0);
    });
  });

  group('pointInPolygon', () {
    final square = const [
      Offset(0, 0),
      Offset(10, 0),
      Offset(10, 10),
      Offset(0, 10),
    ];

    test('inside point', () {
      expect(pointInPolygon(const Offset(5, 5), square), isTrue);
    });

    test('outside point', () {
      expect(pointInPolygon(const Offset(15, 5), square), isFalse);
    });
  });

  group('detectSelfIntersection', () {
    // 最新線分 (5,10)→(5,-5) が底辺 (0,0)-(10,0) を (5,0) で厳密に横切る。
    final crossing = const [
      Offset(0, 0),
      Offset(10, 0),
      Offset(10, 10),
      Offset(5, 10),
      Offset(5, -5),
    ];

    test('detects the crossing and builds a closed loop', () {
      final hit = detectSelfIntersection(crossing, minGap: 1);
      expect(hit, isNotNull);
      expect(hit!.point.dx, closeTo(5, 1e-9));
      expect(hit.point.dy, closeTo(0, 1e-9));
      expect(hit.loop.first, hit.loop.last); // 閉じている
      expect(polygonArea(hit.loop), closeTo(50, 1e-9));
    });

    test('returns null when the new segment does not properly cross', () {
      final collinear = const [
        Offset(0, 0),
        Offset(10, 0),
        Offset(20, 0),
        Offset(30, 0),
      ];
      expect(detectSelfIntersection(collinear, minGap: 1), isNull);
    });

    test('ignores degenerate loops below minLoopArea (continues drawing)', () {
      // 面積50のループは minLoopArea=1000 未満なので確定しない。
      expect(
        detectSelfIntersection(crossing, minGap: 1, minLoopArea: 1000),
        isNull,
      );
      // 閾値以下なら確定する。
      expect(
        detectSelfIntersection(crossing, minGap: 1, minLoopArea: 49),
        isNotNull,
      );
    });

    test('too few points returns null', () {
      expect(
        detectSelfIntersection(const [Offset(0, 0), Offset(1, 1)]),
        isNull,
      );
    });

    test('small loops still confirm (default minLoopArea = 0)', () {
      // 面積50の小さなループでも、既定では確定する。
      expect(detectSelfIntersection(crossing, minGap: 1), isNotNull);
    });

    test('tolerance detects a near-touch that does not strictly cross', () {
      // 最新線分 (3,10)→(3,1) は底辺 y=0 に届かず交差しないが、1だけ近接。
      final nearTouch = const [
        Offset(0, 0),
        Offset(10, 0),
        Offset(10, 10),
        Offset(3, 10),
        Offset(3, 1),
      ];
      expect(detectSelfIntersection(nearTouch, minGap: 1), isNull);
      expect(
        detectSelfIntersection(nearTouch, minGap: 1, tolerance: 2),
        isNotNull,
      );
    });
  });

  group('findProximityClosure', () {
    // 大きめの円状の点列（始点 (0,0) に終点が近づいて閉じる）。
    final circle = const [
      Offset(0, 0),
      Offset(40, 0),
      Offset(40, 40),
      Offset(0, 40),
      Offset(-2, 2), // 終点が始点(0,0)の近く（距離≈2.8）
    ];

    test('closes when the end returns near the start', () {
      final hit = findProximityClosure(
        circle,
        proximity: 6,
        pathGuard: 50,
        minLoopArea: 1,
      );
      expect(hit, isNotNull);
      expect(hit!.loop.first, hit.loop.last); // 閉じている
      expect(hit.segmentIndex, 0); // 始点で閉じる（大きいループ）
    });

    test('does not close when the end is far from earlier points', () {
      final openArc = const [
        Offset(0, 0),
        Offset(40, 0),
        Offset(80, 0),
        Offset(120, 0),
        Offset(160, 0),
      ];
      expect(
        findProximityClosure(openArc, proximity: 6, pathGuard: 50, minLoopArea: 1),
        isNull,
      );
    });

    test('does not close onto the immediate tail (pathGuard)', () {
      // 終点付近の点だけが近い直線的な列。pathGuard により末尾には閉じない。
      final line = const [
        Offset(0, 0),
        Offset(10, 0),
        Offset(20, 0),
        Offset(30, 0),
        Offset(31, 1),
      ];
      expect(
        findProximityClosure(line, proximity: 6, pathGuard: 50, minLoopArea: 1),
        isNull,
      );
    });
  });

  group('boundingBox', () {
    test('computes bounds', () {
      final box = boundingBox(const [
        Offset(1, 2),
        Offset(5, 1),
        Offset(3, 9),
      ]);
      expect(box.left, 1);
      expect(box.top, 1);
      expect(box.right, 5);
      expect(box.bottom, 9);
    });
  });
}
