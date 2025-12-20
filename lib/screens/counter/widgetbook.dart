import 'package:flutter_example_app/screens/counter/presentation.dart';
import 'package:widgetbook/widgetbook.dart';

final counterStories = WidgetbookComponent(
  name: 'CounterScreen',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => CounterPresentation(
        count: 0,
        onIncrement: () {}, // Provide an empty function as a placeholder
      ),
    ),
  ],
);
