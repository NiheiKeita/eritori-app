import 'package:flutter/material.dart';

class LevelSelectPresentation extends StatelessWidget {
  const LevelSelectPresentation({
    super.key,
    required this.unlockedLevel,
    required this.bestScores,
    required this.onTapLevel,
  });

  final int unlockedLevel;
  final Map<int, int> bestScores;
  final ValueChanged<int> onTapLevel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'LEVEL SELECT',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final levelId = index + 1;
                  final isUnlocked = levelId <= unlockedLevel;
                  final bestScore = bestScores[levelId];
                  return _LevelCard(
                    key: ValueKey('level_tile_$levelId'),
                    levelId: levelId,
                    isUnlocked: isUnlocked,
                    bestScore: bestScore,
                    onTap: () => onTapLevel(levelId),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    super.key,
    required this.levelId,
    required this.isUnlocked,
    required this.bestScore,
    required this.onTap,
  });

  final int levelId;
  final bool isUnlocked;
  final int? bestScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isUnlocked ? Colors.black87 : Colors.grey;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? const Color(0xFFFDE7A1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? const Color(0xFFF0C75E) : Colors.grey.shade400,
          ),
        ),
        child: Row(
          children: [
            Text(
              'LEVEL $levelId',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Spacer(),
            if (!isUnlocked)
              const Text(
                '🔒',
                key: ValueKey('level_locked'),
                style: TextStyle(fontSize: 18),
              ),
            if (isUnlocked)
              Text(
                'BEST ${bestScore ?? '--'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
