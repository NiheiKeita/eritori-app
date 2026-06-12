import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/theme/eri_colors.dart';
import '../../domain/models/quality.dart';
import '../../shared/audio/audio_service.dart';
import '../../shared/effects/slice_flash.dart';
import '../../shared/effects/slice_particles.dart';
import 'game_controller.dart';
import 'game_painter.dart';

/// ゲーム画面（純粋UI）。ジェスチャ→[GameController]、回転は Ticker で駆動。
///
/// 成功/失敗の確定時に [onSuccess]/[onFail] を呼ぶ。スコアはなぞり中は出さず
/// （spec §8.2）、確定演出は [SliceFlash] のオーバーレイで見せる。
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.controller,
    required this.onSuccess,
    required this.onFail,
    required this.onExit,
  });

  final GameController controller;
  final VoidCallback onSuccess;
  final VoidCallback onFail;
  final VoidCallback onExit;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final AudioService _audio = AudioService();
  Duration _last = Duration.zero;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onState);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt > 0 && dt < 0.1) widget.controller.tick(dt);
  }

  void _onState() {
    final status = widget.controller.status;
    if (_handled) return;
    if (status == GameStatus.success) {
      _handled = true;
      // 切る瞬間のSE（spec §9.1）。Sランクは専用SE（spec §9.2）。
      _audio.play(Sfx.slice);
      if (widget.controller.result?.score.quality == Quality.s) {
        _audio.play(Sfx.rankS);
      }
      // 演出の後に遷移。
      Future.delayed(const Duration(milliseconds: 650), widget.onSuccess);
    } else if (status == GameStatus.fail) {
      _handled = true;
      _audio.play(Sfx.fail);
      Future.delayed(const Duration(milliseconds: 600), widget.onFail);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audio.dispose();
    widget.controller.removeListener(_onState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final stage = controller.stage;
    final colors = EriColors.of(stage.theme);

    return Scaffold(
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final composite = controller.composite;
          return LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.setCanvasSize(size);
              });

              return Stack(
                fit: StackFit.expand,
                children: [
                  // テーマ背景。
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: colors.backgroundGradient,
                      ),
                    ),
                  ),
                  if (composite == null)
                    const Center(child: CircularProgressIndicator())
                  else
                    GestureDetector(
                      onPanStart: (d) =>
                          controller.onPanStart(d.localPosition),
                      onPanUpdate: (d) =>
                          controller.onPanUpdate(d.localPosition),
                      onPanEnd: (_) => controller.onPanEnd(),
                      child: CustomPaint(
                        painter: GamePainter(
                          eriImage: composite.eriImage,
                          lizardImage: composite.lizardImage,
                          eriRect: composite.eriRect,
                          lizardRect: composite.lizardRect,
                          transform: controller.transform,
                          strokeLocalPoints: controller.stroke.points,
                          glowColor: colors.glow,
                        ),
                      ),
                    ),

                  // 上部 HUD（ステージ名・テーマ）。
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: widget.onExit,
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                          ),
                          const Spacer(),
                          Text(
                            'Lv${stage.levelId}  ${stage.name}',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: colors.glow, blurRadius: 12),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),

                  // 切る瞬間のフラッシュ＋パーティクル（spec §9.1）。
                  if (controller.status == GameStatus.success) ...[
                    SliceParticles(color: colors.primary),
                    SliceFlash(color: colors.glow),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
