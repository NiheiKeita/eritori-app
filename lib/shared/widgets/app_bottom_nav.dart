import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 下タブ（spec §8.1 を改訂）。
///
/// 宝箱は下タブから外し、エリボード上の宝箱オブジェクトから開く。
/// 右端はメニュー（三本線）。
enum AppTab { home, board, menu }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current});

  final AppTab current;

  void _onTap(BuildContext context, int index) {
    switch (AppTab.values[index]) {
      case AppTab.home:
        context.go('/');
      case AppTab.board:
        context.go('/board');
      case AppTab.menu:
        context.go('/menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current.index,
      onDestinationSelected: (i) => _onTap(context, i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'ボード'),
        NavigationDestination(icon: Icon(Icons.menu), label: 'メニュー'),
      ],
    );
  }
}
