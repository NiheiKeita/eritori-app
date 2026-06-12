import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'app/router.dart';
import 'data/repositories/eri_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/storage/local_storage.dart';
import 'state/progress_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 縦持ち専用（spec §1 / §9.6）。
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final progressRepository = SharedPrefsProgressRepository(prefs);
  final progressController = ProgressController(progressRepository);
  final eriRepository = EriRepository(LocalStorage());

  await progressController.load();
  await eriRepository.load();

  // 初回はチュートリアルから（spec §5）。
  final seenTutorial = await progressRepository.getHasSeenTutorial();
  final initialLocation = seenTutorial ? '/' : '/tutorial';

  runApp(
    AppScope(
      progressRepository: progressRepository,
      progressController: progressController,
      eriRepository: eriRepository,
      child: EritoriApp(
        router: AppRouter(initialLocation: initialLocation),
      ),
    ),
  );
}
