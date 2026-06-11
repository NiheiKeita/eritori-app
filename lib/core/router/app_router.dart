import 'package:flutter_example_app/screens/counter/container.dart';
import 'package:go_router/go_router.dart';

import '../../screens/second/second.dart';
import '../../screens/top/top.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'top',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const TopScreen()),
    ),
    GoRoute(
      path: '/second',
      name: 'second',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const SecondScreen()),
    ),
    GoRoute(
      path: '/counter',
      name: 'counter',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const CounterContainer()),
    ),
  ],
);
