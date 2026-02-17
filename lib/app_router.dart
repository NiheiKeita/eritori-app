import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_scope.dart';
import 'screens/coming_soon/coming_soon_container.dart';
import 'screens/game/game_container.dart';
import 'screens/home/home_container.dart';
import 'screens/level_select/level_select_container.dart';
import 'screens/result/result_container.dart';
import 'screens/result/result_controller.dart';
import 'screens/settings/settings_container.dart';
import 'screens/trace_cutout/trace_cutout_screen.dart';
import 'widgets/bottom_nav_presentation.dart';

class AppRouter {
  AppRouter();

  GoRouter createRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            HomeContainer(
              onNavSelected: (item) => _onNavSelected(context, item),
            ),
          ),
        ),
        GoRoute(
          path: '/level-select',
          pageBuilder: (context, state) {
            final scope = AppScope.of(context);
            return _noTransitionPage(
              state,
              LevelSelectContainer(
                controller: scope.levelSelectController,
                onNavSelected: (item) => _onNavSelected(context, item),
              ),
            );
          },
        ),
        GoRoute(
          path: '/game/:levelId',
          pageBuilder: (context, state) {
            final scope = AppScope.of(context);
            final levelId = int.tryParse(state.pathParameters['levelId'] ?? '');
            return _noTransitionPage(
              state,
              GameContainer(
                levelId: levelId ?? 1,
                prefsRepository: scope.prefsRepository,
                levelSelectController: scope.levelSelectController,
              ),
            );
          },
        ),
        GoRoute(
          path: '/result',
          pageBuilder: (context, state) {
            final data = state.extra as ResultData?;
            return _noTransitionPage(
              state,
              ResultContainer(
                data: data ??
                    const ResultData(
                      levelId: 1,
                      score: 0,
                      success: false,
                      bestUpdated: false,
                      unlockedNext: false,
                      unlockedLevel: 1,
                      cutoutBytes: null,
                    ),
              ),
            );
          },
        ),
        GoRoute(
          path: '/coming-soon/:type',
          pageBuilder: (context, state) {
            final type = state.pathParameters['type'] ?? 'rank';
            final title = type == 'shop' ? 'Shop' : 'Ranking';
            return _noTransitionPage(
              state,
              ComingSoonContainer(
                title: title,
                onNavSelected: (item) => _onNavSelected(context, item),
              ),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) {
            final scope = AppScope.of(context);
            return _noTransitionPage(
              state,
              SettingsContainer(
                controller: scope.settingsController,
                levelSelectController: scope.levelSelectController,
                onNavSelected: (item) => _onNavSelected(context, item),
              ),
            );
          },
        ),
        GoRoute(
          path: '/trace-cutout',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const TraceCutoutScreen()),
        ),
      ],
    );
  }

  Page<void> _noTransitionPage(GoRouterState state, Widget child) {
    return NoTransitionPage(key: state.pageKey, child: child);
  }

  void _onNavSelected(BuildContext context, BottomNavItem item) {
    switch (item) {
      case BottomNavItem.home:
        context.go('/');
        break;
      case BottomNavItem.rank:
        context.go('/coming-soon/rank');
        break;
      case BottomNavItem.play:
        context.go('/level-select');
        break;
      case BottomNavItem.shop:
        context.go('/coming-soon/shop');
        break;
      case BottomNavItem.settings:
        context.go('/settings');
        break;
    }
  }
}
