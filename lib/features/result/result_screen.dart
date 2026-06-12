import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_scope.dart';
import '../../app/theme/eri_colors.dart';
import '../../domain/config/stage_catalog.dart';
import '../../domain/models/eri.dart';
import '../../domain/models/quality.dart';
import '../../shared/effects/slice_particles.dart';
import '../../shared/widgets/quality_stamp.dart';
import '../organize/organize_args.dart';
import 'result_args.dart';

/// 成功リザルト（spec §8.3 / §9.2）。スコアをドンと出し、品質スタンプ・自己ベスト更新演出。
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.args});

  final ResultArgs args;

  Future<void> _save(BuildContext context) async {
    final repo = AppScope.of(context).eriRepository;
    final eri = Eri(
      id: const Uuid().v4(),
      stageId: args.stageId,
      stageName: args.stageName,
      score: args.score.score,
      captureRate: args.score.captureRate,
      quality: args.score.quality,
      acquiredAt: DateTime.now(),
      imagePath: '',
      isPersonalBest: args.progress.bestUpdated,
      location: EriLocation.chest,
    );

    if (repo.isChestFull) {
      // 満杯 → 整理画面で入れ替え（spec §8.7）。
      context.push('/organize', extra: OrganizeArgs(candidate: eri, png: args.cutoutPng));
      return;
    }
    await repo.addToChest(eri, args.cutoutPng);
    if (context.mounted) context.go('/chest');
  }

  @override
  Widget build(BuildContext context) {
    final stage = StageCatalog.byId(args.stageId);
    final colors = EriColors.of(stage.theme);
    final score = args.score;
    final ratePct = (score.captureRate * 100).toStringAsFixed(1);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors.backgroundGradient,
              ),
            ),
            child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ScorePop(
                  child: Column(
                    children: [
                      Text(
                        '$ratePct%',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: colors.accent,
                          shadows: [Shadow(color: colors.glow, blurRadius: 24)],
                        ),
                      ),
                      Text(
                        'SCORE ${score.score}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                QualityStamp(quality: score.quality, glow: colors.glow),
                if (args.progress.bestUpdated) ...[
                  const SizedBox(height: 12),
                  Text(
                    '★ 自己ベスト更新！',
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
                if (args.progress.unlockedNext) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lv${args.progress.unlockedLevel} 解放！',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 24),
                _Preview(image: args.cutoutImage),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _save(context),
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('宝箱に保管'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/game/${args.levelId}'),
                      icon: const Icon(Icons.refresh),
                      label: const Text('リトライ'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/level-select'),
                      child: const Text('レベル選択'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('破棄'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
          ),
          // Sランク: 画面全体エフェクト（spec §9.2）。
          if (score.quality == Quality.s)
            Positioned.fill(
              child: SliceParticles(color: colors.accent, count: 40),
            ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.image});
  final dynamic image; // ui.Image

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 160,
        child: RawImage(image: image, fit: BoxFit.contain),
      ),
    );
  }
}

/// スコアのバウンス表示（spec §9.2）。
class _ScorePop extends StatefulWidget {
  const _ScorePop({required this.child});
  final Widget child;

  @override
  State<_ScorePop> createState() => _ScorePopState();
}

class _ScorePopState extends State<_ScorePop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    return ScaleTransition(scale: scale, child: widget.child);
  }
}
