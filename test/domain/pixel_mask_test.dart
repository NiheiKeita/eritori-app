import 'dart:typed_data';

import 'package:flutter_example_app/domain/mask/pixel_mask.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 10x10 の全面不透明マスク（アルファ255）。
  PixelMask fullMask() {
    final alpha = Uint8List(100)..fillRange(0, 100, 255);
    return PixelMask.fromAlpha(10, 10, alpha);
  }

  group('PixelMask', () {
    test('totalOpaque counts all opaque pixels', () {
      expect(fullMask().totalOpaque, 100);
    });

    test('isOpaqueAt respects bounds and threshold', () {
      final mask = fullMask();
      expect(mask.isOpaqueAt(5, 5), isTrue);
      expect(mask.isOpaqueAt(-1, 0), isFalse);
      expect(mask.isOpaqueAt(10, 10), isFalse);
    });

    test('transparent pixels are not opaque', () {
      final alpha = Uint8List(100); // all 0
      final mask = PixelMask.fromAlpha(10, 10, alpha);
      expect(mask.totalOpaque, 0);
      expect(mask.isOpaqueAt(5, 5), isFalse);
    });

    test('countOpaqueInside counts pixels within a loop polygon', () {
      final mask = fullMask();
      // 中央付近の 4x4 四角を囲む（ピクセル中心 (2.5..5.5) が内側）。
      final loop = const [
        Offset(2, 2),
        Offset(6, 2),
        Offset(6, 6),
        Offset(2, 6),
      ];
      final captured = mask.countOpaqueInside(loop);
      // 内側のピクセル中心 x,y in {2.5,3.5,4.5,5.5} → 4x4 = 16。
      expect(captured, 16);
    });

    test('countOpaqueInside on full-area loop captures all', () {
      final mask = fullMask();
      final loop = const [
        Offset(0, 0),
        Offset(10, 0),
        Offset(10, 10),
        Offset(0, 10),
      ];
      expect(mask.countOpaqueInside(loop), 100);
    });
  });
}
