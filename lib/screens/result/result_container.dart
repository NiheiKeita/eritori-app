import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'result_controller.dart';
import 'result_presentation.dart';

class ResultContainer extends StatelessWidget {
  const ResultContainer({super.key, required this.data});

  final ResultData data;

  @override
  Widget build(BuildContext context) {
    final controller = ResultController(data);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return ResultPresentation(
            levelId: controller.data.levelId,
            score: controller.data.score,
            success: controller.data.success,
            bestUpdated: controller.data.bestUpdated,
            unlockedNext: controller.data.unlockedNext,
            unlockedLevel: controller.data.unlockedLevel,
            onRetry: () => context.go('/game/${controller.data.levelId}'),
            onSelectLevel: () => context.go('/level-select'),
          );
        },
      ),
    );
  }
}
