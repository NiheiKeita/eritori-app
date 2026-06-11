import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_example_app/screens/level_select/level_select_controller.dart';
import '../support/fake_prefs_repository.dart';

void main() {
  test('initial unlockedLevel is 1', () async {
    final prefs = FakePrefsRepository();
    final controller = LevelSelectController(prefs);
    await controller.load();
    expect(controller.unlockedLevel, 1);
  });

  test('clear level 1 unlocks level 2', () async {
    final prefs = FakePrefsRepository();
    final controller = LevelSelectController(prefs);
    await controller.load();
    await controller.recordResult(levelId: 1, score: 120, success: true);
    expect(controller.unlockedLevel, 2);
  });

  test('best score updates and saves', () async {
    final prefs = FakePrefsRepository();
    final controller = LevelSelectController(prefs);
    await controller.load();
    await controller.recordResult(levelId: 1, score: 100, success: true);
    await controller.recordResult(levelId: 1, score: 80, success: true);
    await controller.recordResult(levelId: 1, score: 140, success: true);
    expect(controller.bestScore(1), 140);
    expect(prefs.store['best_1'], 140);
  });
}
