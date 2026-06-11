import 'package:flutter/material.dart';

import '../../widgets/bottom_nav_presentation.dart';
import '../level_select/level_select_controller.dart';
import 'settings_controller.dart';
import 'settings_presentation.dart';

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({
    super.key,
    required this.controller,
    required this.levelSelectController,
    required this.onNavSelected,
  });

  final SettingsController controller;
  final LevelSelectController levelSelectController;
  final ValueChanged<BottomNavItem> onNavSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return SettingsPresentation(
            showTutorial: !controller.hasSeenTutorial,
            onToggleTutorial: (value) {
              controller.setHasSeenTutorial(!value);
            },
            onResetProgress: () {
              levelSelectController.resetProgress();
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavPresentation(
        current: BottomNavItem.settings,
        onTap: onNavSelected,
      ),
    );
  }
}
