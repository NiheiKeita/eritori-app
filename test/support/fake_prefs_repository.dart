import 'package:flutter_example_app/storage/prefs_repository.dart';

class FakePrefsRepository implements PrefsRepository {
  final Map<String, Object> _store = {};

  @override
  Future<int> getUnlockedLevel() async {
    return _store['unlocked'] as int? ?? 1;
  }

  @override
  Future<void> setUnlockedLevel(int value) async {
    _store['unlocked'] = value;
  }

  @override
  Future<int?> getBestScore(int level) async {
    return _store['best_$level'] as int?;
  }

  @override
  Future<void> setBestScore(int level, int score) async {
    _store['best_$level'] = score;
  }

  @override
  Future<bool> getHasSeenTutorial() async {
    return _store['tutorial'] as bool? ?? false;
  }

  @override
  Future<void> setHasSeenTutorial(bool value) async {
    _store['tutorial'] = value;
  }

  @override
  Future<void> resetProgress(int maxLevel) async {
    _store['unlocked'] = 1;
    for (var level = 1; level <= maxLevel; level++) {
      _store.remove('best_$level');
    }
  }

  Map<String, Object> get store => Map.unmodifiable(_store);
}
