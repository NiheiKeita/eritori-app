import 'package:flutter/material.dart';

class HomePresentation extends StatelessWidget {
  const HomePresentation({
    super.key,
    required this.onPlay,
    required this.onTraceCutout,
  });

  final VoidCallback onPlay;
  final VoidCallback onTraceCutout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'えりとり',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'えりまきとかげの襟を\n指でそっと取り外そう！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE7A1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    '今日のミッション',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('LEVEL 1に挑戦しよう！'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    key: const ValueKey('home_play'),
                    onPressed: onPlay,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Play'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: onTraceCutout,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('なぞって切り抜き'),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
