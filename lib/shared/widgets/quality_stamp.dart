import 'package:flutter/material.dart';

import '../../domain/models/quality.dart';

/// 品質ランクのスタンプ（spec §9.2: D→S で派手さが段階的に増す）。
class QualityStamp extends StatelessWidget {
  const QualityStamp({super.key, required this.quality, required this.glow});

  final Quality quality;
  final Color glow;

  Color get _color => switch (quality) {
        Quality.s => const Color(0xFFFFE600),
        Quality.a => const Color(0xFFFF6BD6),
        Quality.b => const Color(0xFF6BFFB0),
        Quality.c => const Color(0xFF8AB4FF),
        Quality.d => const Color(0xFFB0B0B0),
      };

  double get _blur => switch (quality) {
        Quality.s => 32,
        Quality.a => 20,
        Quality.b => 12,
        Quality.c => 6,
        Quality.d => 2,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _color, width: 4),
        boxShadow: [BoxShadow(color: _color, blurRadius: _blur)],
      ),
      child: Text(
        quality.label,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: _color,
          shadows: [Shadow(color: glow, blurRadius: _blur)],
        ),
      ),
    );
  }
}
