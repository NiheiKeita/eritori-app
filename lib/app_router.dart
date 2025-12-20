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
import 'widgets/bottom_nav_presentation.dart';

class AppRouter {
  AppRouter();

  GoRouter createRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return HomeContainer(
              onNavSelected: (item) => _onNavSelected(context, item),
            );
          },
        ),
        GoRoute(
          path: '/level-select',
          builder: (context, state) {
            final scope = AppScope.of(context);
            return LevelSelectContainer(
              controller: scope.levelSelectController,
              onNavSelected: (item) => _onNavSelected(context, item),
            );
          },
        ),
        GoRoute(
          path: '/game/:levelId',
          builder: (context, state) {
            final scope = AppScope.of(context);
            final levelId = int.tryParse(state.pathParameters['levelId'] ?? '');
            return GameContainer(
              levelId: levelId ?? 1,
              prefsRepository: scope.prefsRepository,
              levelSelectController: scope.levelSelectController,
            );
          },
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) {
            final data = state.extra as ResultData?;
            return ResultContainer(
              data: data ??
                  const ResultData(
                    levelId: 1,
                    score: 0,
                    success: false,
                    bestUpdated: false,
                    unlockedNext: false,
                    unlockedLevel: 1,
                  ),
            );
          },
        ),
        GoRoute(
          path: '/coming-soon/:type',
          builder: (context, state) {
            final type = state.pathParameters['type'] ?? 'rank';
            final title = type == 'shop' ? 'Shop' : 'Ranking';
            return ComingSoonContainer(
              title: title,
              onNavSelected: (item) => _onNavSelected(context, item),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) {
            final scope = AppScope.of(context);
            return SettingsContainer(
              controller: scope.settingsController,
              levelSelectController: scope.levelSelectController,
              onNavSelected: (item) => _onNavSelected(context, item),
            );
          },
        ),
      ],
    );
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
