import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../domain/config/stage_catalog.dart';

/// 設定（spec §8.1）。プレイヤー名・チュートリアル再生・進捗リセット。
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    AppScope.of(context).progressRepository.getPlayerName().then((name) {
      if (mounted) _nameController.text = name ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = AppScope.of(context).progressRepository;

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('プレイヤー名（共有画像に表示）'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '名前（任意）',
            ),
            onSubmitted: progress.setPlayerName,
            onChanged: progress.setPlayerName,
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('チュートリアルを再生'),
            onTap: () => context.go('/tutorial'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.redAccent),
            title: const Text('進捗をリセット',
                style: TextStyle(color: Colors.redAccent)),
            onTap: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final scope = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('進捗をリセット'),
        content: const Text('解放レベルと自己ベストが初期化されます。よろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('リセット'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await scope.progressRepository.resetProgress(StageCatalog.maxLevel);
    await scope.progressController.load();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('進捗をリセットしました')),
      );
    }
  }
}
