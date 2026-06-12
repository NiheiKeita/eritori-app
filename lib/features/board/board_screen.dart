import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../data/repositories/eri_repository.dart';
import '../../data/storage/local_storage.dart';
import '../../domain/models/eri.dart';
import '../../shared/share/board_sharer.dart';
import '../../shared/widgets/app_bottom_nav.dart';

/// エリボード（spec §8.6 / §9.5 / §10）。
///
/// 1枚の大きなボードに襟画像を自由配置。ドラッグで移動、重ね順あり（重ねられる）、
/// タップで詳細ポップアップ。ピンチで拡大縮小。SNS共有はボード全体を画像化。
class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final GlobalKey _boardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final repo = scope.eriRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('エリボード'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () => BoardSharer.share(_boardKey),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.board),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          final eris = [...repo.onBoard]..sort((a, b) => a.boardZ.compareTo(b.boardZ));
          final totalScore = eris.fold<int>(0, (sum, e) => sum + e.score);

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    RepaintBoundary(
                  key: _boardKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final boardSize = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF101826), Color(0xFF1B1030)],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // ヘッダ（名前・総スコア）。
                            Positioned(
                              left: 16,
                              top: 12,
                              right: 16,
                              child: _Header(
                                progressRepository: scope.progressRepository,
                                totalScore: totalScore,
                              ),
                            ),
                            if (eris.isEmpty)
                              const Center(
                                child: Text(
                                  '宝箱から襟をボードへ移動してね',
                                  style: TextStyle(color: Colors.white38),
                                ),
                              ),
                            for (final eri in eris)
                              _BoardPiece(
                                key: ValueKey(eri.id),
                                eri: eri,
                                boardSize: boardSize,
                                repo: repo,
                                onTapDetail: () =>
                                    _showDetail(context, repo, eri),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                    ),
                    // 宝箱オブジェクト（タップで宝箱画面へ）。共有画像に写さないため
                    // RepaintBoundary の外に重ねる。
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: _ChestButton(onTap: () => context.push('/chest')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, EriRepository repo, Eri eri) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${eri.stageName}  ${eri.quality.label}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('スコア: ${eri.score}'),
            Text('捕捉率: ${(eri.captureRate * 100).toStringAsFixed(1)}%'),
            Text('獲得: ${eri.acquiredAt.toLocal()}'.split('.').first),
            if (eri.isPersonalBest) const Text('★ 自己ベスト記録'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              repo.move(eri.id, EriLocation.chest);
              Navigator.pop(dialogContext);
            },
            child: const Text('宝箱へ戻す'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progressRepository, required this.totalScore});

  final dynamic progressRepository;
  final int totalScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<String?>(
          future: progressRepository.getPlayerName(),
          builder: (context, snap) => Text(
            '${snap.data ?? "Player"} のエリボード',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          '総展示スコア $totalScore',
          style: const TextStyle(color: Colors.white60),
        ),
      ],
    );
  }
}

/// ボード上の1枚。ドラッグで移動、ピンチで拡大縮小、タップで詳細。
class _BoardPiece extends StatefulWidget {
  const _BoardPiece({
    super.key,
    required this.eri,
    required this.boardSize,
    required this.repo,
    required this.onTapDetail,
  });

  final Eri eri;
  final Size boardSize;
  final EriRepository repo;
  final VoidCallback onTapDetail;

  @override
  State<_BoardPiece> createState() => _BoardPieceState();
}

class _BoardPieceState extends State<_BoardPiece> {
  // ドラッグ・ピンチ中のローカル値（確定時にリポジトリへ反映）。
  late double _x = widget.eri.boardX;
  late double _y = widget.eri.boardY;
  late double _scale = widget.eri.boardScale;
  double _gestureStartScale = 1;

  static const double _baseSize = 120; // 拡大率1のときの一辺(px)

  @override
  void didUpdateWidget(_BoardPiece old) {
    super.didUpdateWidget(old);
    // 外部更新（宝箱へ戻す等）に追従。
    _x = widget.eri.boardX;
    _y = widget.eri.boardY;
    _scale = widget.eri.boardScale;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.boardSize.width;
    final h = widget.boardSize.height;
    final size = _baseSize * _scale;
    final left = _x * w - size / 2;
    final top = _y * h - size / 2;
    final provider = LocalStorage.imageProvider(widget.eri.imagePath);

    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: GestureDetector(
        onTap: widget.onTapDetail,
        onScaleStart: (_) {
          _gestureStartScale = _scale;
          widget.repo.bringToFront(widget.eri.id);
        },
        onScaleUpdate: (details) {
          setState(() {
            // 移動（フォーカス点の移動量を正規化）。
            _x = (_x + details.focalPointDelta.dx / w).clamp(0.0, 1.0);
            _y = (_y + details.focalPointDelta.dy / h).clamp(0.0, 1.0);
            _scale = (_gestureStartScale * details.scale).clamp(0.4, 3.0);
          });
        },
        onScaleEnd: (_) {
          widget.repo.updateBoardPlacement(
            widget.eri.id,
            boardX: _x,
            boardY: _y,
            boardScale: _scale,
          );
        },
        child: Transform.rotate(
          angle: widget.eri.boardRotation,
          child: provider == null
              ? const ColoredBox(color: Colors.white10)
              : Image(image: provider, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// ボード上に置く宝箱オブジェクト。タップで宝箱画面へ遷移する。
class _ChestButton extends StatelessWidget {
  const _ChestButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF3A2A12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7B24B), width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x66E7B24B), blurRadius: 12),
          ],
        ),
        child: const Center(
          child: Text('🧰', style: TextStyle(fontSize: 30)),
        ),
      ),
    );
  }
}
