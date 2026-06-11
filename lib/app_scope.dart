import 'package:flutter/material.dart';

import 'screens/level_select/level_select_controller.dart';
import 'screens/settings/settings_controller.dart';
import 'storage/prefs_repository.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.prefsRepository,
    required this.levelSelectController,
    required this.settingsController,
    required super.child,
  });

  final PrefsRepository prefsRepository;
  final LevelSelectController levelSelectController;
  final SettingsController settingsController;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) {
    return prefsRepository != oldWidget.prefsRepository ||
        levelSelectController != oldWidget.levelSelectController ||
        settingsController != oldWidget.settingsController;
  }
}
