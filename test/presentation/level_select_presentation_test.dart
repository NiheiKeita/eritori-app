import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_example_app/screens/level_select/level_select_presentation.dart';

void main() {
  testWidgets('shows lock for locked levels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LevelSelectPresentation(
          unlockedLevel: 1,
          bestScores: const {1: 120},
          onTapLevel: (_) {},
        ),
      ),
    );

    expect(find.text('LEVEL 1'), findsOneWidget);
    expect(find.text('🔒'), findsWidgets);
  });
}
