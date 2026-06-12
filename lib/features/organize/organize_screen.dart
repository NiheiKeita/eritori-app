import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../shared/widgets/eri_tile.dart';
import 'organize_args.dart';

/// 整理画面（spec §8.7）。宝箱満杯時、新規襟と既存襟の入れ替えを選ぶ。
class OrganizeScreen extends StatefulWidget {
  const OrganizeScreen({super.key, required this.args});

  final OrganizeArgs args;

  @override
  State<OrganizeScreen> createState() => _OrganizeScreenState();
}

class _OrganizeScreenState extends State<OrganizeScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context).eriRepository;
    final candidate = widget.args.candidate;

    return Scaffold(
      appBar: AppBar(title: const Text('宝箱がいっぱい：入れ替え')),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          final chest = repo.inChest;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text('新しく獲得した襟', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      height: 150,
                      child: EriTile(eri: candidate),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '↓ 入れ替える襟を選んでください',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: chest.length,
                  itemBuilder: (context, index) {
                    final eri = chest[index];
                    return EriTile(
                      eri: eri,
                      selected: _selectedId == eri.id,
                      onTap: () => setState(() => _selectedId = eri.id),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('キャンセル'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _selectedId == null
                              ? null
                              : () async {
                                  await repo.swapInChest(
                                    _selectedId!,
                                    candidate,
                                    widget.args.png,
                                  );
                                  if (context.mounted) context.go('/chest');
                                },
                          child: const Text('入れ替え確定'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
