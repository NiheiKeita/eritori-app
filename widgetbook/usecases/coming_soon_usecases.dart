import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:flutter_example_app/screens/coming_soon/coming_soon_presentation.dart';

WidgetbookComponent comingSoonUsecases() {
  return WidgetbookComponent(
    name: 'ComingSoonPresentation',
    useCases: [
      WidgetbookUseCase(
        name: 'Ranking',
        builder: (context) => const ComingSoonPresentation(
          title: 'Ranking',
          subtitle: '近日公開！',
        ),
      ),
    ],
  );
}
