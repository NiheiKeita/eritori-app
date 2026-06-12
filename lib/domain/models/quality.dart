/// 襟の品質ランク。`captureRate`(0..1) から決定する。
///
/// 閾値は [GameConfig] に集約しているが、enum 自体は純粋なドメイン値として
/// ここに定義し、UI 依存を持たない。
enum Quality {
  d,
  c,
  b,
  a,
  s;

  /// 表示用ラベル（D/C/B/A/S）。
  String get label => name.toUpperCase();
}
