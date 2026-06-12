import 'package:flutter/foundation.dart';

import '../data/repositories/progress_repository.dart';
import '../domain/config/stage_catalog.dart';
import '../domain/scoring/score_calculator.dart';

/// 解放レベルと自己ベストのインメモリ状態（spec §7.1 / §8.1）。
///
/// 進捗ロジック（クリア判定→解放・自己ベスト更新）をここに集約し、UI から呼ぶだけにする。
class ProgressController extends ChangeNotifier {
  ProgressController(this._repo, {ScoreCalculator? calc})
      : _calc = calc ?? const ScoreCalculator();

  final ProgressRepository _repo;
  final ScoreCalculator _calc;

  int _unlockedLevel = 1;
  final Map<int, int> _bestScores = {};

  int get unlockedLevel => _unlockedLevel;
  int? bestScore(int level) => _bestScores[level];

  Future<void> load() async {
    _unlockedLevel = await _repo.getUnlockedLevel();
    _bestScores.clear();
    for (final stage in StageCatalog.stages) {
      final best = await _repo.getBestScore(stage.levelId);
      if (best != null) _bestScores[stage.levelId] = best;
    }
    notifyListeners();
  }

  /// プレイ結果を反映する。戻り値で「自己ベスト更新」「次レベル解放」を返す。
  Future<ProgressUpdate> recordResult(int level, int score) async {
    final stage = StageCatalog.byLevel(level);
    final prevBest = _bestScores[level];
    final bestUpdated = prevBest == null || score > prevBest;
    if (bestUpdated) {
      _bestScores[level] = score;
      await _repo.setBestScore(level, score);
    }

    var unlockedNext = false;
    final cleared = _calc.isCleared(score, stage.clearScore);
    if (cleared && level == _unlockedLevel && level < StageCatalog.maxLevel) {
      _unlockedLevel = level + 1;
      await _repo.setUnlockedLevel(_unlockedLevel);
      unlockedNext = true;
    }

    notifyListeners();
    return ProgressUpdate(
      bestUpdated: bestUpdated,
      cleared: cleared,
      unlockedNext: unlockedNext,
      unlockedLevel: _unlockedLevel,
    );
  }
}

class ProgressUpdate {
  const ProgressUpdate({
    required this.bestUpdated,
    required this.cleared,
    required this.unlockedNext,
    required this.unlockedLevel,
  });

  final bool bestUpdated;
  final bool cleared;
  final bool unlockedNext;
  final int unlockedLevel;
}
