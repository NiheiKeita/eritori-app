import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'usecases/bottom_nav_usecases.dart';
import 'usecases/coming_soon_usecases.dart';
import 'usecases/game_usecases.dart';
import 'usecases/home_usecases.dart';
import 'usecases/level_select_usecases.dart';
import 'usecases/result_usecases.dart';
import 'usecases/settings_usecases.dart';

void main() {
  runApp(const EritoriWidgetbook());
}

class EritoriWidgetbook extends StatelessWidget {
  const EritoriWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      appBuilder: (context, child) => MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1F6F75),
          ),
          useMaterial3: true,
        ),
        home: Scaffold(body: child),
      ),
      directories: [
        WidgetbookFolder(
          name: 'Screens',
          children: [
            homeUsecases(),
            levelSelectUsecases(),
            gameUsecases(),
            resultUsecases(),
            comingSoonUsecases(),
            settingsUsecases(),
          ],
        ),
        WidgetbookFolder(
          name: 'Widgets',
          children: [
            bottomNavUsecases(),
          ],
        ),
      ],
    );
  }
}
