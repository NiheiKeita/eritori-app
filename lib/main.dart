import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_router.dart';
import 'app_scope.dart';
import 'screens/game/level_config.dart';
import 'screens/level_select/level_select_controller.dart';
import 'screens/settings/settings_controller.dart';
import 'storage/prefs_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final prefsRepository = SharedPrefsRepository(prefs);
  await LevelConfig.loadFromAsset();
  final levelSelectController = LevelSelectController(prefsRepository);
  final settingsController = SettingsController(prefsRepository);
  await levelSelectController.load();
  await settingsController.load();

  runApp(
    AppScope(
      prefsRepository: prefsRepository,
      levelSelectController: levelSelectController,
      settingsController: settingsController,
      child: MyApp(appRouter: AppRouter()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'えりとり',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6F75)),
        scaffoldBackgroundColor: const Color(0xFFF7F3E8),
        useMaterial3: true,
      ),
      routerConfig: appRouter.createRouter(),
    );
  }
}
