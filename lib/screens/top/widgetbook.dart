import 'package:widgetbook/widgetbook.dart';

import 'top.dart';

final topStories = WidgetbookComponent(
  name: 'TopScreen',
  useCases: [
    WidgetbookUseCase(name: 'Default', builder: (context) => const TopScreen()),
  ],
);
