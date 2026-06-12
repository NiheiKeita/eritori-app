import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 失敗画面（spec §8.4 / §9.3）。成功と明確に別トーン（赤系）。獲得なし。
class FailScreen extends StatefulWidget {
  const FailScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<FailScreen> createState() => _FailScreenState();
}

class _FailScreenState extends State<FailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5A0E0E), Color(0xFF1A0303)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ビクッと跳ねる変顔リアクション（spec §9.3, プレースホルダ）。
                AnimatedBuilder(
                  animation: _c,
                  builder: (context, child) {
                    final shake = (1 - _c.value) *
                        12 *
                        (((_c.value * 10).floor().isEven) ? 1 : -1);
                    return Transform.translate(
                      offset: Offset(shake, 0),
                      child: Transform.scale(
                        scale: 1 + (1 - _c.value) * 0.3,
                        child: child,
                      ),
                    );
                  },
                  child: const Text('💥', style: TextStyle(fontSize: 96)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'しっぱい…',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'トカゲや襟の外に触れた / 囲めなかった',
                  style: TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/game/${widget.levelId}'),
                      icon: const Icon(Icons.refresh),
                      label: const Text('リトライ'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/level-select'),
                      child: const Text('レベル選択'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
