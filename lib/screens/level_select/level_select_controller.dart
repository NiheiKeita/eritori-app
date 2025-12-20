import 'package:flutter/material.dart';

import '../../storage/prefs_repository.dart';
import '../game/level_config.dart';

class LevelProgressResult {
  const LevelProgressResult({
    required this.bestUpdated,
    required this.unlockedNext,
    required this.unlockedLevel,
  });

  final bool bestUpdated;
  final bool unlockedNext;
  final int unlockedLevel;
}

class LevelSelectController extends ChangeNotifier {
  LevelSelectController(this._prefsRepository);

  final PrefsRepository _prefsRepository;

  int unlockedLevel = 1;
  final Map<int, int> bestScores = {};
  bool isLoaded = false;

  Future<void> load() async {
    unlockedLevel = await _prefsRepository.getUnlockedLevel();
    for (var level = 1; level <= LevelConfig.maxLevel; level++) {
      final best = await _prefsRepository.getBestScore(level);
      if (best != null) {
        bestScores[level] = best;
      }
    }
    isLoaded = true;
    notifyListeners();
  }

  bool isUnlocked(int levelId) => levelId <= unlockedLevel;

  int? bestScore(int levelId) => bestScores[levelId];

  Future<LevelProgressResult> recordResult({
    required int levelId,
    required int score,
    required bool success,
  }) async {
    var bestUpdated = false;
    var unlockedNext = false;

    if (success) {
      final currentBest = bestScores[levelId] ?? 0;
      if (score > currentBest) {
        bestScores[levelId] = score;
        bestUpdated = true;
        await _prefsRepository.setBestScore(levelId, score);
      }
      if (levelId == unlockedLevel &&
          unlockedLevel < LevelConfig.maxLevel) {
        unlockedLevel += 1;
        unlockedNext = true;
        await _prefsRepository.setUnlockedLevel(unlockedLevel);
      }
    }

    notifyListeners();
    return LevelProgressResult(
      bestUpdated: bestUpdated,
      unlockedNext: unlockedNext,
      unlockedLevel: unlockedLevel,
    );
  }

  Future<void> resetProgress() async {
    unlockedLevel = 1;
    bestScores.clear();
    await _prefsRepository.resetProgress(LevelConfig.maxLevel);
    notifyListeners();
  }
}
