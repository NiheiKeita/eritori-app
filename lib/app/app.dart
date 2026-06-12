import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

/// アプリのルート（MaterialApp.router）。
class EritoriApp extends StatelessWidget {
  const EritoriApp({super.key, required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'エリトリ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router.build(),
    );
  }
}
