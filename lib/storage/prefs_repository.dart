import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_keys.dart';

abstract class PrefsRepository {
  Future<int> getUnlockedLevel();
  Future<void> setUnlockedLevel(int value);

  Future<int?> getBestScore(int level);
  Future<void> setBestScore(int level, int score);

  Future<bool> getHasSeenTutorial();
  Future<void> setHasSeenTutorial(bool value);

  Future<void> resetProgress(int maxLevel);
}

class SharedPrefsRepository implements PrefsRepository {
  SharedPrefsRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<int> getUnlockedLevel() async {
    return _prefs.getInt(PrefsKeys.unlockedLevel) ?? 1;
  }

  @override
  Future<void> setUnlockedLevel(int value) async {
    await _prefs.setInt(PrefsKeys.unlockedLevel, value);
  }

  @override
  Future<int?> getBestScore(int level) async {
    return _prefs.getInt(PrefsKeys.bestScoreForLevel(level));
  }

  @override
  Future<void> setBestScore(int level, int score) async {
    await _prefs.setInt(PrefsKeys.bestScoreForLevel(level), score);
  }

  @override
  Future<bool> getHasSeenTutorial() async {
    return _prefs.getBool(PrefsKeys.hasSeenTutorial) ?? false;
  }

  @override
  Future<void> setHasSeenTutorial(bool value) async {
    await _prefs.setBool(PrefsKeys.hasSeenTutorial, value);
  }

  @override
  Future<void> resetProgress(int maxLevel) async {
    await _prefs.setInt(PrefsKeys.unlockedLevel, 1);
    for (var level = 1; level <= maxLevel; level++) {
      await _prefs.remove(PrefsKeys.bestScoreForLevel(level));
    }
  }
}
