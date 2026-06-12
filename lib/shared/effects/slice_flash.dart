import 'package:flutter/material.dart';

/// 切る瞬間の発光フラッシュ（spec §9.1）。
///
/// 確定時に一瞬白〜テーマ色のフラッシュをかけて「スパッ」と切れた印象を出す。
class SliceFlash extends StatefulWidget {
  const SliceFlash({super.key, required this.color});

  final Color color;

  @override
  State<SliceFlash> createState() => _SliceFlashState();
}

class _SliceFlashState extends State<SliceFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
  }

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
        builder: (context, _) {
          final t = _c.value;
          final opacity = (1 - t) * 0.7;
          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.white, widget.color.withValues(alpha: 0.0)],
                  radius: 0.4 + t * 0.8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
