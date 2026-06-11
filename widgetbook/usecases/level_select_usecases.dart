import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:flutter_example_app/screens/level_select/level_select_presentation.dart';

WidgetbookComponent levelSelectUsecases() {
  return WidgetbookComponent(
    name: 'LevelSelectPresentation',
    useCases: [
      WidgetbookUseCase(
        name: 'Unlocked 1',
        builder: (context) => LevelSelectPresentation(
          unlockedLevel: 1,
          bestScores: const {1: 120},
          onTapLevel: (_) {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Unlocked 3',
        builder: (context) => LevelSelectPresentation(
          unlockedLevel: 3,
          bestScores: const {1: 120, 2: 230, 3: 310},
          onTapLevel: (_) {},
        ),
      ),
    ],
  );
}
