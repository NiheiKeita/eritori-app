import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:flutter_example_app/screens/settings/settings_presentation.dart';

WidgetbookComponent settingsUsecases() {
  return WidgetbookComponent(
    name: 'SettingsPresentation',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (context) => SettingsPresentation(
          showTutorial: false,
          onToggleTutorial: (_) {},
          onResetProgress: () {},
        ),
      ),
    ],
  );
}
