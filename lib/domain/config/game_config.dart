import '../models/quality.dart';

/// ゲームバランス定数の集約（spec §7）。
///
/// クリア基準・品質閾値・回転速度・容量・演出時間など、調整対象の数値は
/// **すべてここに集約**する。マジックナンバーをコードに散らさないこと。
/// 将来的に JSON 外出しできるよう、static const で表現し参照点を一本化する。
class GameConfig {
  GameConfig._();

  // --- スコア正規化 ---
  /// 正規化スコアの最大値（全端末・全襟共通）。
  static const int maxScore = 10000;

  // --- 品質ランク閾値（捕捉率 0..1, 下限以上で該当ランク, spec §7.2）---
  static const double qualityS = 0.95;
  static const double qualityA = 0.88;
  static const double qualityB = 0.78;
  static const double qualityC = 0.65;
  // それ未満は D

  /// 捕捉率 [rate] から品質ランクを決定する純粋関数。
  static Quality qualityFromRate(double rate) {
    if (rate >= qualityS) return Quality.s;
    if (rate >= qualityA) return Quality.a;
    if (rate >= qualityB) return Quality.b;
    if (rate >= qualityC) return Quality.c;
    return Quality.d;
  }

  // --- マスク/判定解像度 ---
  /// 判定用にスプライトを縮小する長辺ピクセル（spec §6.4 メモ）。
  static const int maskLongEdge = 512;

  /// 本体マスクの不透明判定アルファ閾値（0..1, spec §6.3）。
  static const double opaqueAlphaThreshold = 0.5;

  // --- なぞり確定の最小条件（誤確定防止, spec §6.2b）---
  /// なぞり点の間引き距離（ローカル単位）。前点からこの距離以上離れた時だけ追加し、
  /// ほぼ共線の極小線分による判定の不安定さを防ぐ。
  static const double minPointDist = 8.0;

  /// 自己交差判定で除外する直近線分本数（隣接線分の誤検出回避）。厳密交差なので 1 で十分。
  static const int minIntersectionGap = 1;

  /// 閉じ判定を開始する最小点数。小さく素早いループも拾えるよう低め。
  static const int minPointsBeforeClose = 5;

  /// 確定に必要な最小ループ面積（ローカル座標）。**小さくても交差したら切り取りたい**ため、
  /// ゼロ面積の退化ループだけを弾くごく小さい値にする。
  static const double minLoopArea = 1.0;

  /// 線の太さ用の許容距離（ローカル単位）。線が見た目で触れたら交差とみなす。
  /// 暴発防止のため必ず [minPointDist] より小さくする（直前の自分の線に常時触れないように）。
  static const double intersectionToleranceLocal = minPointDist * 0.7;

  // --- 保存画像 ---
  /// 切り取り襟・共有用に保存する画像の長辺ピクセル（spec §4）。
  static const int savedImageLongEdge = 512;

  // --- 容量（spec §7.4）---
  static const int chestBaseCapacity = 5;
  static const int boardBaseCapacity = 2;

  /// レベルアップ報酬による容量拡張（level→追加数）。MVPでは定義のみ。
  static const Map<int, int> chestCapacityRewards = {5: 5, 10: 5, 20: 10};

  // --- 演出（juice, spec §9）---
  /// 切る瞬間のスローモーション時間。
  static const Duration sliceSlowMotion = Duration(milliseconds: 120);

  /// スコア表示のバウンス時間。
  static const Duration scorePop = Duration(milliseconds: 450);

  /// 画面シェイク強度（論理px）。
  static const double screenShakeMagnitude = 12;

  /// 失敗リアクションの時間。
  static const Duration failReaction = Duration(milliseconds: 600);
}
