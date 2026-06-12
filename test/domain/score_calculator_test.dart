import 'package:flutter_example_app/domain/config/game_config.dart';
import 'package:flutter_example_app/domain/models/quality.dart';
import 'package:flutter_example_app/domain/scoring/score_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = ScoreCalculator();

  group('compute', () {
    test('full capture is max score and S rank', () {
      final r = calc.compute(capturedPixels: 1000, totalPixels: 1000);
      expect(r.captureRate, 1.0);
      expect(r.score, GameConfig.maxScore);
      expect(r.quality, Quality.s);
    });

    test('half capture', () {
      final r = calc.compute(capturedPixels: 500, totalPixels: 1000);
      expect(r.captureRate, 0.5);
      expect(r.score, 5000);
      expect(r.quality, Quality.d);
    });

    test('zero total pixels does not divide by zero', () {
      final r = calc.compute(capturedPixels: 0, totalPixels: 0);
      expect(r.captureRate, 0.0);
      expect(r.score, 0);
      expect(r.quality, Quality.d);
    });

    test('capture rate clamps above 1', () {
      final r = calc.compute(capturedPixels: 1200, totalPixels: 1000);
      expect(r.captureRate, 1.0);
      expect(r.score, GameConfig.maxScore);
    });
  });

  group('qualityFromRate boundaries', () {
    test('S at 0.95', () {
      expect(GameConfig.qualityFromRate(0.95), Quality.s);
    });
    test('A at 0.88', () {
      expect(GameConfig.qualityFromRate(0.88), Quality.a);
      expect(GameConfig.qualityFromRate(0.949), Quality.a);
    });
    test('B at 0.78', () {
      expect(GameConfig.qualityFromRate(0.78), Quality.b);
    });
    test('C at 0.65', () {
      expect(GameConfig.qualityFromRate(0.65), Quality.c);
    });
    test('D below 0.65', () {
      expect(GameConfig.qualityFromRate(0.6499), Quality.d);
      expect(GameConfig.qualityFromRate(0.0), Quality.d);
    });
  });

  group('isCleared', () {
    test('meets threshold', () {
      expect(calc.isCleared(7000, 7000), isTrue);
      expect(calc.isCleared(6999, 7000), isFalse);
    });
  });
}
