import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_example_app/screens/game/game_controller.dart';
import 'package:flutter_example_app/screens/game/level_config.dart';
import '../support/fake_prefs_repository.dart';

void main() {
  late FakePrefsRepository prefs;
  late GameController controller;

  setUp(() async {
    prefs = FakePrefsRepository();
    controller = GameController(prefsRepository: prefs);
    await controller.loadTutorialState();
  });

  test('start and panUpdate add points', () {
    controller.onPanStart(
      position: const Offset(10, 10),
      size: const Size(200, 400),
      config: LevelConfig.forLevel(1),
    );
    controller.onPanUpdate(
      position: const Offset(20, 20),
      size: const Size(200, 400),
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    expect(controller.points.length, 2);
  });

  test('close detection sets success', () {
    final size = const Size(200, 400);
    controller.onPanStart(
      position: const Offset(50, 200),
      size: size,
      config: LevelConfig.forLevel(1),
    );
    controller.onPanUpdate(
      position: const Offset(150, 200),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanUpdate(
      position: const Offset(160, 260),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanUpdate(
      position: const Offset(140, 320),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanUpdate(
      position: const Offset(60, 320),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanUpdate(
      position: const Offset(52, 202),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanEnd(size: size, config: LevelConfig.forLevel(1));
    expect(controller.status, GameStatus.success);
  });

  test('ng area contact fails immediately', () {
    final size = const Size(200, 400);
    controller.onPanStart(
      position: const Offset(40, 120),
      size: size,
      config: LevelConfig.forLevel(1),
    );
    controller.onPanUpdate(
      position: const Offset(120, 140),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    expect(controller.status, GameStatus.failed);
  });

  test('success calculates score', () {
    final size = const Size(200, 400);
    controller.onPanStart(
      position: const Offset(30, 250),
      size: size,
      config: LevelConfig.forLevel(1),
    );
    controller.onPanUpdate(
      position: const Offset(170, 250),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanUpdate(
      position: const Offset(170, 320),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanUpdate(
      position: const Offset(100, 340),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanUpdate(
      position: const Offset(30, 320),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanUpdate(
      position: const Offset(30, 250),
      size: size,
      config: LevelConfig.forLevel(1),
      swayOffset: Offset.zero,
    );
    controller.onPanEnd(size: size, config: LevelConfig.forLevel(1));
    expect(controller.status, GameStatus.success);
    expect(controller.score, greaterThan(0));
  });
}
