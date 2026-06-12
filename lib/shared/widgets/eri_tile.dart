import 'package:flutter/material.dart';

import '../../data/storage/local_storage.dart';
import '../../domain/models/eri.dart';

/// 襟のサムネタイル（宝箱・ボード・整理で共用, spec §8.5-8.7）。
class EriTile extends StatelessWidget {
  const EriTile({
    super.key,
    required this.eri,
    this.onTap,
    this.selected = false,
  });

  final Eri eri;
  final VoidCallback? onTap;
  final bool selected;

  Widget _thumbnail() {
    final provider = LocalStorage.imageProvider(eri.imagePath);
    if (provider == null) {
      return const Center(child: Icon(Icons.image, color: Colors.white24));
    }
    return Image(image: provider, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.amberAccent : Colors.white12,
            width: selected ? 3 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(child: _thumbnail()),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    eri.stageName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${eri.quality.label} ${eri.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
