import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../domain/scoring/score_calculator.dart';
import '../../state/progress_controller.dart';

/// リザルト画面へ渡す確定結果（spec §8.3）。go_router の extra で受け渡す。
class ResultArgs {
  const ResultArgs({
    required this.levelId,
    required this.stageId,
    required this.stageName,
    required this.score,
    required this.cutoutImage,
    required this.cutoutPng,
    required this.progress,
  });

  final int levelId;
  final String stageId;
  final String stageName;
  final ScoreResult score;
  final ui.Image cutoutImage;
  final Uint8List cutoutPng;
  final ProgressUpdate progress;
}
