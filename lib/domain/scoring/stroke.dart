import 'dart:ui';

/// なぞり線（ローカル座標の点列）。
///
/// すべての点は襟スプライトのローカル座標で保持する（spec §6.1）。
/// 判定・面積計算はこのローカル座標で行うため、回転レベルでも静止レベルと
/// 同一のコードで扱える。
class Stroke {
  Stroke();

  final List<Offset> _points = <Offset>[];

  List<Offset> get points => List.unmodifiable(_points);
  int get length => _points.length;
  bool get isEmpty => _points.isEmpty;
  Offset? get last => _points.isEmpty ? null : _points.last;
  Offset? get first => _points.isEmpty ? null : _points.first;

  void clear() => _points.clear();

  void add(Offset point) => _points.add(point);

  /// 末尾に追加しようとしている線分 [last]→[candidate] が、既存の線分と
  /// 交差するか。直近 [gap] 本の線分は隣接ノイズとして除外する。
  ///
  /// 純粋に幾何のみを扱い、交差判定本体は [polygon_math] に委譲する。
  Stroke copy() {
    final s = Stroke();
    s._points.addAll(_points);
    return s;
  }
}
