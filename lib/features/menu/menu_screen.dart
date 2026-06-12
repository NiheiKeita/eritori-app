import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_bottom_nav.dart';

/// メニュー画面（下タブ右端の三本線から開く）。設定・チュートリアル等の入口。
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メニュー')),
      bottomNavigationBar: const AppBottomNav(current: AppTab.menu),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('宝箱'),
            onTap: () => context.push('/chest'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            onTap: () => context.push('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('チュートリアル'),
            onTap: () => context.go('/tutorial'),
          ),
        ],
      ),
    );
  }
}
