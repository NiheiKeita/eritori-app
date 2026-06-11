import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:flutter_example_app/screens/home/home_presentation.dart';

WidgetbookComponent homeUsecases() {
  return WidgetbookComponent(
    name: 'HomePresentation',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (context) => HomePresentation(onPlay: () {}),
      ),
    ],
  );
}
