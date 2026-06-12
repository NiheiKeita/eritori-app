import 'package:shared_preferences/shared_preferences.dart';

/// 進捗（解放レベル・各ステージ自己ベスト・チュートリアル既読・プレイヤー名）。
///
/// spec §4 は progress.json を指定するが、本プロジェクト既存規約に合わせ
/// `shared_preferences`（実体はローカル永続ストア）を用いる。襟メタ/画像は
/// [EriRepository] が別途ファイル保存する。
abstract class ProgressRepository {
  Future<int> getUnlockedLevel();
  Future<void> setUnlockedLevel(int value);
  Future<int?> getBestScore(int level);
  Future<void> setBestScore(int level, int score);
  Future<bool> getHasSeenTutorial();
  Future<void> setHasSeenTutorial(bool value);
  Future<String?> getPlayerName();
  Future<void> setPlayerName(String name);
  Future<void> resetProgress(int maxLevel);
}

class SharedPrefsProgressRepository implements ProgressRepository {
  SharedPrefsProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kUnlocked = 'unlocked_level';
  static const _kBest = 'best_score_';
  static const _kTutorial = 'has_seen_tutorial';
  static const _kPlayerName = 'player_name';

  @override
  Future<int> getUnlockedLevel() async => _prefs.getInt(_kUnlocked) ?? 1;

  @override
  Future<void> setUnlockedLevel(int value) async =>
      _prefs.setInt(_kUnlocked, value);

  @override
  Future<int?> getBestScore(int level) async =>
      _prefs.getInt('$_kBest$level');

  @override
  Future<void> setBestScore(int level, int score) async =>
      _prefs.setInt('$_kBest$level', score);

  @override
  Future<bool> getHasSeenTutorial() async =>
      _prefs.getBool(_kTutorial) ?? false;

  @override
  Future<void> setHasSeenTutorial(bool value) async =>
      _prefs.setBool(_kTutorial, value);

  @override
  Future<String?> getPlayerName() async => _prefs.getString(_kPlayerName);

  @override
  Future<void> setPlayerName(String name) async =>
      _prefs.setString(_kPlayerName, name);

  @override
  Future<void> resetProgress(int maxLevel) async {
    await _prefs.setInt(_kUnlocked, 1);
    for (var level = 1; level <= maxLevel; level++) {
      await _prefs.remove('$_kBest$level');
    }
  }
}
