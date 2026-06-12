import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../data/repositories/eri_repository.dart';
import '../../domain/models/eri.dart';
import '../../shared/widgets/eri_tile.dart';

/// 宝箱（spec §8.5）。エリボード上の宝箱から開くサブ画面。グリッド表示・「ボードへ移動」。
class ChestScreen extends StatelessWidget {
  const ChestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context).eriRepository;
    return Scaffold(
      appBar: AppBar(
        title: const Text('宝箱'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/board'),
        ),
      ),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          final eris = repo.inChest;
          final capacity = repo.chestCapacity;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${eris.length} / $capacity',
                  style: const TextStyle(fontSize: 16),
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
                  itemCount: capacity,
                  itemBuilder: (context, index) {
                    if (index >= eris.length) {
                      return _EmptySlot();
                    }
                    final eri = eris[index];
                    return EriTile(
                      eri: eri,
                      onTap: () => _showActions(context, repo, eri),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showActions(BuildContext context, EriRepository repo, Eri eri) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('エリボードへ移動'),
              onTap: () {
                repo.move(eri.id, EriLocation.board);
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('破棄'),
              onTap: () {
                repo.remove(eri.id);
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Icon(Icons.add, color: Colors.white24),
      ),
    );
  }
}
