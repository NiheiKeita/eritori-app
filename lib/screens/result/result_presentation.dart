import 'package:flutter/material.dart';

class ResultPresentation extends StatelessWidget {
  const ResultPresentation({
    super.key,
    required this.levelId,
    required this.score,
    required this.success,
    required this.bestUpdated,
    required this.unlockedNext,
    required this.unlockedLevel,
    required this.onRetry,
    required this.onSelectLevel,
  });

  final int levelId;
  final int score;
  final bool success;
  final bool bestUpdated;
  final bool unlockedNext;
  final int unlockedLevel;
  final VoidCallback onRetry;
  final VoidCallback onSelectLevel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              success ? 'CLEAR!' : 'FAILED',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: success
                        ? const Color(0xFF2F7D6D)
                        : const Color(0xFFD9534F),
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EBD2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'SCORE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$score',
                    key: const ValueKey('result_score'),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (bestUpdated)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'BEST UPDATE!',
                        style: TextStyle(
                          color: Color(0xFF2F7D6D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (unlockedNext)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'LEVEL ${unlockedLevel} UNLOCKED!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F6F75),
                  ),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              key: const ValueKey('result_retry'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('もう一回'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const ValueKey('result_level_select'),
              onPressed: onSelectLevel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('レベル選択'),
            ),
          ],
        ),
      ),
    );
  }
}
