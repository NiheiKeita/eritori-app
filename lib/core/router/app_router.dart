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
      builder: (context, state) => const TopScreen(),
    ),
    GoRoute(
      path: '/second',
      name: 'second',
      builder: (context, state) => const SecondScreen(),
    ),
    GoRoute(
      path: '/counter',
      name: 'counter',
      builder: (context, state) => const CounterContainer(),
    ),
  ],
);
