import 'package:flutter/material.dart';

import '../../storage/prefs_repository.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefsRepository);

  final PrefsRepository _prefsRepository;

  bool hasSeenTutorial = false;
  bool isLoaded = false;

  Future<void> load() async {
    hasSeenTutorial = await _prefsRepository.getHasSeenTutorial();
    isLoaded = true;
    notifyListeners();
  }

  Future<void> setHasSeenTutorial(bool value) async {
    hasSeenTutorial = value;
    await _prefsRepository.setHasSeenTutorial(value);
    notifyListeners();
  }
}
