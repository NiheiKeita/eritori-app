import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'screens/counter/widgetbook.dart';
import 'screens/top/widgetbook.dart';

void main() {
  runApp(const WidgetbookHotReload());
}

class WidgetbookHotReload extends StatelessWidget {
  const WidgetbookHotReload({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookCategory(
          name: 'Screens',
          children: [counterStories, topStories],
        ),
      ],
      addons: [
        ThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF464544),
                ),
                useMaterial3: true,
              ),
            ),
          ],
          themeBuilder: (context, theme, child) =>
              Theme(data: theme, child: child),
        ),
      ],
    );
  }
}
