import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/bottom_nav_presentation.dart';
import 'level_select_controller.dart';
import 'level_select_presentation.dart';

class LevelSelectContainer extends StatelessWidget {
  const LevelSelectContainer({
    super.key,
    required this.controller,
    required this.onNavSelected,
  });

  final LevelSelectController controller;
  final ValueChanged<BottomNavItem> onNavSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return LevelSelectPresentation(
            unlockedLevel: controller.unlockedLevel,
            bestScores: controller.bestScores,
            onTapLevel: (levelId) {
              if (!controller.isUnlocked(levelId)) {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('まだ解放されていません'),
                      content: const Text('LEVEL 1をクリアしよう！'),
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
                return;
              }
              context.go('/game/$levelId');
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavPresentation(
        current: BottomNavItem.play,
        onTap: onNavSelected,
      ),
    );
  }
}
