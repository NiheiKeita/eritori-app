import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme/eri_colors.dart';
import '../../domain/config/stage_catalog.dart';
import '../../domain/models/stage.dart';
import '../../shared/widgets/app_bottom_nav.dart';

/// ホーム=レベル選択（spec §8.1）。下タブ起点。未解放はロック+必要基準表示。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = AppScope.of(context).progressController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('エリトリ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.home),
      body: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final stage in StageCatalog.stages)
                _LevelCard(
                  stage: stage,
                  unlocked: stage.isUnlocked(progress.unlockedLevel),
                  best: progress.bestScore(stage.levelId),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.stage,
    required this.unlocked,
    required this.best,
  });

  final Stage stage;
  final bool unlocked;
  final int? best;

  @override
  Widget build(BuildContext context) {
    final colors = EriColors.of(stage.theme);
    final bestPct =
        best == null ? '—' : '${(best! / 100).toStringAsFixed(1)}%';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: unlocked ? colors.primary : Colors.white12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: unlocked ? () => context.go('/game/${stage.levelId}') : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.2),
                  border: Border.all(color: colors.primary),
                ),
                child: unlocked
                    ? Text(
                        'Lv${stage.levelId}',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(Icons.lock, color: Colors.white54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: colors.glow, blurRadius: 12)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unlocked
                          ? '自己ベスト $bestPct${stage.rotates ? "  ・回転" : ""}'
                          : 'クリア基準 ${(stage.clearScore / 100).toStringAsFixed(0)}% で解放',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              if (unlocked)
                Icon(Icons.play_circle_fill, color: colors.primary, size: 36),
            ],
          ),
        ),
      ),
    );
  }
}
