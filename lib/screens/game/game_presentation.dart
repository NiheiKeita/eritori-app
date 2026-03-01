import 'package:flutter/material.dart';

import 'frill_painter.dart';
import 'game_assets.dart';
import 'game_controller.dart';
import 'level_config.dart';

class GamePresentation extends StatelessWidget {
  const GamePresentation({
    super.key,
    required this.levelId,
    required this.status,
    required this.points,
    required this.score,
    required this.showTutorial,
    required this.config,
    required this.swayOffset,
    required this.backgroundImage,
    required this.faceImage,
    required this.faceScale,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onExit,
  });

  final int levelId;
  final GameStatus status;
  final List<Offset> points;
  final int score;
  final bool showTutorial;
  final LevelConfig config;
  final Offset swayOffset;
  final ImageProvider backgroundImage;
  final ImageProvider faceImage;
  final double faceScale;
  final void Function(Offset position, Size size) onPanStart;
  final void Function(Offset position, Size size) onPanUpdate;
  final void Function(Size size) onPanEnd;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  key: const ValueKey('game_back'),
                  onPressed: onExit,
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                Text(
                  'LEVEL $levelId',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                _ScoreChip(score: score),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return GestureDetector(
                  key: const ValueKey('game_gesture'),
                  onPanStart: (details) =>
                      onPanStart(details.localPosition, size),
                  onPanUpdate: (details) =>
                      onPanUpdate(details.localPosition, size),
                  onPanEnd: (_) => onPanEnd(size),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image(
                          image: backgroundImage,
                          fit: gameBackgroundFit,
                        ),
                      ),
                      _FaceImageLayer(
                        faceImage: faceImage,
                        config: config,
                        swayOffset: swayOffset,
                        size: size,
                        faceScale: faceScale,
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: FrillPainter(
                            points: points,
                            status: status,
                            config: config,
                            swayOffset: swayOffset,
                          ),
                        ),
                      ),
                      if (showTutorial)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: _HintBanner(),
                          ),
                        ),
                      if (status == GameStatus.failed)
                        const _ResultOverlay(
                          text: 'FAILED',
                          color: Color(0xFFFF6B6B),
                        ),
                      if (status == GameStatus.success)
                        const _ResultOverlay(
                          text: 'SUCCESS!',
                          color: Color(0xFF4CC9A6),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  const _HintBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E7A0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '指で襟を囲んでね',
        key: ValueKey('game_hint'),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E4D4F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'SCORE $score',
        key: const ValueKey('game_score'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _FaceImageLayer extends StatelessWidget {
  const _FaceImageLayer({
    required this.faceImage,
    required this.config,
    required this.swayOffset,
    required this.size,
    required this.faceScale,
  });

  final ImageProvider faceImage;
  final LevelConfig config;
  final Offset swayOffset;
  final Size size;
  final double faceScale;

  @override
  Widget build(BuildContext context) {
    final face = config.resolvedBody(size, swayOffset);
    final scaledRadius = face.radius * faceScale;
    final rect = Rect.fromCenter(
      center: face.center,
      width: scaledRadius * 2,
      height: scaledRadius * 2,
    );
    return Positioned.fromRect(
      rect: rect,
      child: ClipOval(
        child: Image(image: faceImage, fit: BoxFit.cover),
      ),
    );
  }
}
