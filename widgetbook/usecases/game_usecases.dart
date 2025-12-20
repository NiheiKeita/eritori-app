import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:flutter_example_app/screens/game/game_controller.dart';
import 'package:flutter_example_app/screens/game/game_assets.dart';
import 'package:flutter_example_app/screens/game/game_presentation.dart';
import 'package:flutter_example_app/screens/game/level_config.dart';

WidgetbookComponent gameUsecases() {
  return WidgetbookComponent(
    name: 'GamePresentation',
    useCases: [
      WidgetbookUseCase(
        name: 'Playing',
        builder: (context) => GamePresentation(
          levelId: 1,
          status: GameStatus.drawing,
          points: const [
            Offset(40, 300),
            Offset(100, 320),
            Offset(160, 360),
          ],
          score: 42,
          showTutorial: true,
          config: LevelConfig.forLevel(1),
          swayOffset: Offset.zero,
          backgroundImage: defaultBackgroundImage(),
          frillImage: defaultBackgroundImage(),
          onPanStart: (_, __) {},
          onPanUpdate: (_, __) {},
          onPanEnd: (_) {},
          onExit: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Failed',
        builder: (context) => GamePresentation(
          levelId: 1,
          status: GameStatus.failed,
          points: const [
            Offset(60, 260),
            Offset(140, 300),
          ],
          score: 0,
          showTutorial: false,
          config: LevelConfig.forLevel(1),
          swayOffset: Offset.zero,
          backgroundImage: defaultBackgroundImage(),
          frillImage: defaultBackgroundImage(),
          onPanStart: (_, __) {},
          onPanUpdate: (_, __) {},
          onPanEnd: (_) {},
          onExit: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Success',
        builder: (context) => GamePresentation(
          levelId: 1,
          status: GameStatus.success,
          points: const [
            Offset(40, 300),
            Offset(100, 220),
            Offset(180, 300),
            Offset(120, 360),
            Offset(40, 300),
          ],
          score: 128,
          showTutorial: false,
          config: LevelConfig.forLevel(1),
          swayOffset: Offset.zero,
          backgroundImage: defaultBackgroundImage(),
          frillImage: defaultBackgroundImage(),
          onPanStart: (_, __) {},
          onPanUpdate: (_, __) {},
          onPanEnd: (_) {},
          onExit: () {},
        ),
      ),
    ],
  );
}
