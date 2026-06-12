import '../config/game_config.dart';
import '../models/quality.dart';

/// スコア計算結果（捕捉率→正規化スコア→品質）。
class ScoreResult {
  const ScoreResult({
    required this.capturedPixels,
    required this.totalPixels,
    required this.captureRate,
    required this.score,
    required this.quality,
  });

  final int capturedPixels;
  final int totalPixels;
  final double captureRate; // 0..1
  final int score; // 0..GameConfig.maxScore
  final Quality quality;
}

/// 捕捉率→正規化スコア→品質を求める純粋関数群（spec §6.4）。
///
/// UI・描画に一切依存しない。ピクセルカウントは呼び出し側（マスク層）が行い、
/// ここでは数値変換と判定のみを担う。
class ScoreCalculator {
  const ScoreCalculator();

  /// 囲んだ内側の襟非透過ピクセル数 [capturedPixels] と襟全体の非透過総数
  /// [totalPixels] から結果を組み立てる。
  ScoreResult compute({
    required int capturedPixels,
    required int totalPixels,
  }) {
    final rate = totalPixels <= 0
        ? 0.0
        : (capturedPixels / totalPixels).clamp(0.0, 1.0);
    final score = (rate * GameConfig.maxScore).round();
    return ScoreResult(
      capturedPixels: capturedPixels,
      totalPixels: totalPixels,
      captureRate: rate,
      score: score,
      quality: GameConfig.qualityFromRate(rate),
    );
  }

  /// 正規化スコア [score] がステージのクリア基準 [clearScore] を満たすか。
  bool isCleared(int score, int clearScore) => score >= clearScore;
}
