import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_example_app/screens/game/game_controller.dart';
import 'package:flutter_example_app/screens/game/game_presentation.dart';
import 'package:flutter_example_app/screens/game/level_config.dart';

void main() {
  testWidgets('shows score and tutorial hint when enabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GamePresentation(
          levelId: 1,
          status: GameStatus.drawing,
          points: const [],
          score: 50,
          showTutorial: true,
          config: LevelConfig.forLevel(1),
          swayOffset: Offset.zero,
          onPanStart: (_, __) {},
          onPanUpdate: (_, __) {},
          onPanEnd: (_) {},
          onExit: () {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('game_score')), findsOneWidget);
    expect(find.byKey(const ValueKey('game_hint')), findsOneWidget);
  });
}
