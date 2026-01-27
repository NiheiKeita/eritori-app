import 'package:flutter/material.dart';
import 'package:flutter_example_app/widgets/bottom_nav_presentation.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent bottomNavUsecases() {
  return WidgetbookComponent(
    name: 'BottomNavPresentation',
    useCases: [
      WidgetbookUseCase(
        name: 'Play Highlight',
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF7F3E8),
          bottomNavigationBar: BottomNavPresentation(
            current: BottomNavItem.play,
            onTap: (_) {},
          ),
        ),
      ),
    ],
  );
}
