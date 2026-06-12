import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/config/stage_catalog.dart';
import '../../state/progress_controller.dart';
import '../result/result_args.dart';
import 'game_assets.dart';
import 'game_controller.dart';
import 'game_screen.dart';

/// ゲーム画面のコンテナ。Controller生成・アセット読込・結果遷移を担う。
class GameContainer extends StatefulWidget {
  const GameContainer({
    super.key,
    required this.levelId,
    required this.progressController,
  });

  final int levelId;
  final ProgressController progressController;

  @override
  State<GameContainer> createState() => _GameContainerState();
}

class _GameContainerState extends State<GameContainer> {
  late GameController _controller;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final stage = StageCatalog.byLevel(widget.levelId);
    _controller = GameController(stage: stage)
      ..initRandomAngle(math.Random());
    GameAssets.load(stage).then((composite) {
      if (mounted) _controller.loadAssets(composite);
    });
  }

  Future<void> _onSuccess() async {
    final result = _controller.result;
    if (result == null) return;
    final stage = _controller.stage;
    final progress = await widget.progressController
        .recordResult(stage.levelId, result.score.score);
    if (!mounted) return;
    context.pushReplacement(
      '/result',
      extra: ResultArgs(
        levelId: stage.levelId,
        stageId: stage.id,
        stageName: stage.name,
        score: result.score,
        cutoutImage: result.cutoutImage,
        cutoutPng: result.cutoutPng,
        progress: progress,
      ),
    );
  }

  void _onFail() {
    if (!mounted) return;
    context.pushReplacement('/fail/${widget.levelId}');
  }

  void _onExit() => context.go('/level-select');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      controller: _controller,
      onSuccess: _onSuccess,
      onFail: _onFail,
      onExit: _onExit,
    );
  }
}
