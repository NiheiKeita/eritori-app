import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';

/// チュートリアル（spec §8.8）。Lv1 の実操作ガイドへ誘導し、初回フラグを保存する。
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = AppScope.of(context).progressRepository;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B3D1E), Color(0xFF041109)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'あそびかた',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                ..._steps.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('● ', style: TextStyle(color: Color(0xFF39FF7A))),
                        Expanded(
                          child: Text(
                            s,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await progress.setHasSeenTutorial(true);
                      if (context.mounted) context.go('/game/1');
                    },
                    child: const Text('Lv1 でやってみる'),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await progress.setHasSeenTutorial(true);
                    if (context.mounted) context.go('/');
                  },
                  child: const Text('スキップ', style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const List<String> _steps = [
    '指で襟（エリマキ）をなぞって、ぐるっと一周させよう。',
    'なぞった線が交わった瞬間に「切り取り」確定！',
    'トカゲの顔に触れると失敗。顔をよけて大きくえぐろう。',
    '囲んだ襟が大きいほど高スコア。95%以上で S ランク！',
  ];
}
