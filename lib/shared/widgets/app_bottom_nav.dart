import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 下タブ（spec §8.1: ホーム・宝箱・エリボードの起点）。
enum AppTab { home, chest, board }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current});

  final AppTab current;

  void _onTap(BuildContext context, int index) {
    switch (AppTab.values[index]) {
      case AppTab.home:
        context.go('/');
      case AppTab.chest:
        context.go('/chest');
      case AppTab.board:
        context.go('/board');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current.index,
      onDestinationSelected: (i) => _onTap(context, i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
        NavigationDestination(icon: Icon(Icons.inventory_2), label: '宝箱'),
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'ボード'),
      ],
    );
  }
}
