import 'package:go_router/go_router.dart';

import '../features/board/board_screen.dart';
import '../features/chest/chest_screen.dart';
import '../features/fail/fail_screen.dart';
import '../features/game/game_container.dart';
import '../features/home/home_screen.dart';
import '../features/menu/menu_screen.dart';
import '../features/organize/organize_args.dart';
import '../features/organize/organize_screen.dart';
import '../features/result/result_args.dart';
import '../features/result/result_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tutorial/tutorial_screen.dart';
import 'app_scope.dart';

/// アプリのルーティング（spec §5）。
class AppRouter {
  AppRouter({required this.initialLocation});

  /// 初回はチュートリアルから（spec §5）。
  final String initialLocation;

  GoRouter build() {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/level-select',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/tutorial',
          builder: (context, state) => const TutorialScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/chest',
          builder: (context, state) => const ChestScreen(),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: '/board',
          builder: (context, state) => const BoardScreen(),
        ),
        GoRoute(
          path: '/game/:levelId',
          builder: (context, state) {
            final levelId =
                int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1;
            return GameContainer(
              levelId: levelId,
              progressController: AppScope.of(context).progressController,
            );
          },
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) {
            final args = state.extra as ResultArgs?;
            if (args == null) return const HomeScreen();
            return ResultScreen(args: args);
          },
        ),
        GoRoute(
          path: '/fail/:levelId',
          builder: (context, state) {
            final levelId =
                int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1;
            return FailScreen(levelId: levelId);
          },
        ),
        GoRoute(
          path: '/organize',
          builder: (context, state) {
            final args = state.extra as OrganizeArgs?;
            if (args == null) return const ChestScreen();
            return OrganizeScreen(args: args);
          },
        ),
      ],
    );
  }
}
