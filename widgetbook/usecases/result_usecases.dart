import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:flutter_example_app/screens/result/result_presentation.dart';

WidgetbookComponent resultUsecases() {
  return WidgetbookComponent(
    name: 'ResultPresentation',
    useCases: [
      WidgetbookUseCase(
        name: 'Success Best',
        builder: (context) => ResultPresentation(
          levelId: 1,
          score: 230,
          success: true,
          bestUpdated: true,
          unlockedNext: true,
          unlockedLevel: 2,
          cutoutBytes: null,
          onRetry: () {},
          onSelectLevel: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Failed',
        builder: (context) => ResultPresentation(
          levelId: 2,
          score: 0,
          success: false,
          bestUpdated: false,
          unlockedNext: false,
          unlockedLevel: 2,
          cutoutBytes: null,
          onRetry: () {},
          onSelectLevel: () {},
        ),
      ),
    ],
  );
}
