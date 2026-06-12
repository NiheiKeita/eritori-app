import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 切る瞬間に襟の小片が風で舞うパーティクル（spec §9.1）。
///
/// 自前 CustomPainter。`seedAngle` で散布方向に再現性のある変化を与える
/// （ワークフロー/テストでの決定性のため Random は使わない）。
class SliceParticles extends StatefulWidget {
  const SliceParticles({
    super.key,
    required this.color,
    this.count = 24,
    this.seed = 0,
  });

  final Color color;
  final int count;
  final int seed;

  @override
  State<SliceParticles> createState() => _SliceParticlesState();
}

class _SliceParticlesState extends State<SliceParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            t: _c.value,
            color: widget.color,
            count: widget.count,
            seed: widget.seed,
          ),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.t,
    required this.color,
    required this.count,
    required this.seed,
  });

  final double t;
  final Color color;
  final int count;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.2);
    final paint = Paint()..color = color.withValues(alpha: (1 - t).clamp(0, 1));
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 + seed * 0.13;
      final speed = 120 + (i % 5) * 40;
      final dist = speed * t;
      final gravity = 180 * t * t;
      final pos = center +
          Offset(math.cos(angle) * dist, math.sin(angle) * dist + gravity);
      final r = (1 - t) * (4 + (i % 3) * 2);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + t * 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 1.4),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}
