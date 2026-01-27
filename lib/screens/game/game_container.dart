import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../storage/prefs_repository.dart';
import '../level_select/level_select_controller.dart';
import '../result/result_controller.dart';
import 'game_assets.dart';
import 'cutout.dart';
import 'game_controller.dart';
import 'game_presentation.dart';
import 'level_config.dart';

class GameContainer extends StatefulWidget {
  const GameContainer({
    super.key,
    required this.levelId,
    required this.prefsRepository,
    required this.levelSelectController,
  });

  final int levelId;
  final PrefsRepository prefsRepository;
  final LevelSelectController levelSelectController;

  @override
  State<GameContainer> createState() => _GameContainerState();
}

class _GameContainerState extends State<GameContainer>
    with SingleTickerProviderStateMixin {
  late final GameController _controller;
  late final AnimationController _swayController;
  final ImageProvider _backgroundImage = defaultBackgroundImage();
  final ImageProvider _faceImage = defaultFaceImage();
  bool _hasNavigated = false;
  Offset _swayOffset = Offset.zero;
  Size _lastSize = Size.zero;

  LevelConfig get _config => LevelConfig.forLevel(widget.levelId);

  @override
  void initState() {
    super.initState();
    _controller = GameController(prefsRepository: widget.prefsRepository)
      ..addListener(_onControllerChanged)
      ..loadTutorialState();
    _controller.start();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(_updateSway);
    if (_config.swayAmplitudeFactor > 0) {
      _swayController.repeat();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _swayController.dispose();
    super.dispose();
  }

  void _updateSway() {
    if (_lastSize == Size.zero) {
      return;
    }
    final sway = _config.swayOffset(_lastSize, _swayController.value);
    setState(() {
      _swayOffset = sway;
    });
  }

  Future<void> _onControllerChanged() async {
    if (_hasNavigated) {
      return;
    }
    if (_controller.status == GameStatus.success ||
        _controller.status == GameStatus.failed) {
      _hasNavigated = true;
      final success = _controller.status == GameStatus.success;
      LevelProgressResult? progressResult;
      CutoutResult? cutoutResult;
      if (success) {
        if (_lastSize != Size.zero) {
          final bodyCenter =
              _config.resolvedBody(_lastSize, _swayOffset).center;
          final cutoutScore = calculateCutoutScore(
            points: _controller.points,
            centerPoint: bodyCenter,
            size: _lastSize,
          );
          _controller.updateScore(cutoutScore);
        }
        progressResult = await widget.levelSelectController.recordResult(
          levelId: widget.levelId,
          score: max(_controller.score, 0),
          success: true,
        );
        if (_lastSize != Size.zero) {
          final bodyCenter =
              _config.resolvedBody(_lastSize, _swayOffset).center;
          try {
            cutoutResult = await createCutout(
              background: _backgroundImage,
              size: _lastSize,
              points: _controller.points,
              centerPoint: bodyCenter,
            ).timeout(const Duration(milliseconds: 400));
          } catch (_) {
            cutoutResult = null;
          }
        }
      }
      if (!mounted) {
        return;
      }
      context.go(
        '/result',
        extra: ResultData(
          levelId: widget.levelId,
          score: _controller.score,
          success: success,
          bestUpdated: progressResult?.bestUpdated ?? false,
          unlockedNext: progressResult?.unlockedNext ?? false,
          unlockedLevel: progressResult?.unlockedLevel ??
              widget.levelSelectController.unlockedLevel,
          cutoutBytes: cutoutResult?.bytes,
        ),
      );
    }
  }

  void _handleExit() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return GamePresentation(
            levelId: widget.levelId,
            status: _controller.status,
            points: _controller.points,
            score: _controller.score,
            showTutorial: _controller.showTutorial,
            config: _config,
            swayOffset: _swayOffset,
            backgroundImage: _backgroundImage,
            faceImage: _faceImage,
            onPanStart: (position, size) {
              _lastSize = size;
              _controller.onPanStart(
                position: position,
                size: size,
                config: _config,
              );
            },
            onPanUpdate: (position, size) {
              _lastSize = size;
              _controller.onPanUpdate(
                position: position,
                size: size,
                config: _config,
                swayOffset: _swayOffset,
              );
            },
            onPanEnd: (size) {
              _lastSize = size;
              _controller.onPanEnd(size: size, config: _config);
            },
            onExit: _handleExit,
          );
        },
      ),
    );
  }
}
