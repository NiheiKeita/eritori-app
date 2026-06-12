/// 多角形・線分の純粋幾何ユーティリティ（spec §6.2 / §6.4）。
///
/// すべて UI 非依存の純粋関数。`Offset` は `dart:ui` の値型だが Widget には
/// 依存しないため、`flutter_test` で単体テスト可能。
library;

import 'dart:math';
import 'dart:ui';

/// 自己交差の結果。閉じたループ（[loop]）と、交差した既存線分のインデックス。
class SelfIntersection {
  const SelfIntersection({
    required this.point,
    required this.loop,
    required this.segmentIndex,
  });

  /// 交差点（ローカル座標）。
  final Offset point;

  /// 交差で閉じた多角形（交差点で始まり交差点で閉じる点列）。
  final List<Offset> loop;

  /// 交差した既存線分の始点インデックス。
  final int segmentIndex;
}

/// 2線分 a-b と c-d が交差するか（端点接触含む）。
bool segmentsIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
  double cross(Offset a, Offset b, Offset c) =>
      (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);

  bool onSegment(Offset a, Offset b, Offset c) =>
      min(a.dx, b.dx) <= c.dx &&
      c.dx <= max(a.dx, b.dx) &&
      min(a.dy, b.dy) <= c.dy &&
      c.dy <= max(a.dy, b.dy);

  final d1 = cross(p1, p2, p3);
  final d2 = cross(p1, p2, p4);
  final d3 = cross(p3, p4, p1);
  final d4 = cross(p3, p4, p2);

  if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
    return true;
  }
  if (d1 == 0 && onSegment(p1, p2, p3)) return true;
  if (d2 == 0 && onSegment(p1, p2, p4)) return true;
  if (d3 == 0 && onSegment(p3, p4, p1)) return true;
  if (d4 == 0 && onSegment(p3, p4, p2)) return true;
  return false;
}

/// 2線分の交差点（交わらなければ null）。
Offset? segmentIntersectionPoint(Offset a, Offset b, Offset c, Offset d) {
  final r = b - a;
  final s = d - c;
  final rxs = r.dx * s.dy - r.dy * s.dx;
  if (rxs == 0) return null; // 平行/共線
  final cma = c - a;
  final t = (cma.dx * s.dy - cma.dy * s.dx) / rxs;
  final u = (cma.dx * r.dy - cma.dy * r.dx) / rxs;
  if (t < 0 || t > 1 || u < 0 || u > 1) return null;
  return a + r * t;
}

/// 2線分 a-b と c-d が**厳密に**交差するか（端点接触・共線は false）。
///
/// 早期確定バグ対策（隣接・近接の誤検出回避）。前回導入した距離トレランスは
/// 過剰検出の原因だったため撤去し、厳密交差のみで判定する（仮説②③④への対応）。
bool properSegmentsIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
  double cross(Offset a, Offset b, Offset c) =>
      (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
  final d1 = cross(p3, p4, p1);
  final d2 = cross(p3, p4, p2);
  final d3 = cross(p1, p2, p3);
  final d4 = cross(p1, p2, p4);
  return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}

/// 点列 [points] の**最新線分** points[n-2]→points[n-1] が、過去の線分のいずれかと
/// 交差するかを調べ、**最初に見つかった交差**で閉ループを返す
/// （8の字は最初の交差で確定: spec §6.2）。
///
/// - 厳密交差に加え、線の太さ分の許容距離 [tolerance]（ローカル単位）以内で線分が
///   触れていれば交差として扱う。[tolerance] は **点の間引き距離より小さい前提**で渡すこと
///   （直前の自分の線に常時触れて暴発するのを防ぐため）。
/// - 隣接線分（最新線分と頂点を共有する直前の線分）は [minGap] 本ぶん除外する。
/// - できる閉ループの面積が [minLoopArea] 未満なら退化（ゼロ面積）として無視し確定しない。
///   小さくても交差したら切り取れるよう、[minLoopArea] は既定 0（実機ではごく小さい値）。
/// 交差が無ければ null。
SelfIntersection? detectSelfIntersection(
  List<Offset> points, {
  int minGap = 1,
  double minLoopArea = 0,
  double tolerance = 0,
}) {
  final n = points.length;
  if (n < 4) return null;
  final a = points[n - 2];
  final b = points[n - 1];
  // 過去線分 index i: points[i]→points[i+1]。
  // 最新線分の直前(i=n-3)が隣接。minGap本ぶん末尾側を除外する（i は 0..n-3-minGap）。
  final maxI = n - 3 - minGap;
  for (var i = 0; i <= maxI; i++) {
    final c = points[i];
    final d = points[i + 1];
    final crosses = properSegmentsIntersect(a, b, c, d);
    final touches =
        !crosses && tolerance > 0 && segmentDistance(a, b, c, d) <= tolerance;
    if (!crosses && !touches) continue;
    // 厳密交差ならその交点、太さで触れた場合は最近接点の中点。
    final cross = crosses
        ? (segmentIntersectionPoint(a, b, c, d) ?? b)
        : _closestApproachMidpoint(a, b, c, d);
    // 閉ループ: 交差点 → points[i+1 .. n-2] → 交差点（最新点 b は交点の先にあり含めない）。
    final loop = <Offset>[cross, ...points.sublist(i + 1, n - 1), cross];
    if (polygonArea(loop) < minLoopArea) {
      continue; // 退化ループ（面積ほぼゼロ）は無視して継続。
    }
    return SelfIntersection(point: cross, loop: loop, segmentIndex: i);
  }
  return null;
}

/// 2線分 a-b, c-d の最短距離（線の太さ判定用）。
double segmentDistance(Offset a, Offset b, Offset c, Offset d) {
  if (segmentsIntersect(a, b, c, d)) return 0;
  return [
    _pointSegmentDistance(a, c, d),
    _pointSegmentDistance(b, c, d),
    _pointSegmentDistance(c, a, b),
    _pointSegmentDistance(d, a, b),
  ].reduce((v, e) => v < e ? v : e);
}

double _pointSegmentDistance(Offset p, Offset a, Offset b) =>
    (p - _closestPointOnSegment(p, a, b)).distance;

Offset _closestPointOnSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final lenSq = ab.dx * ab.dx + ab.dy * ab.dy;
  if (lenSq == 0) return a;
  final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / lenSq)
      .clamp(0.0, 1.0);
  return Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
}

/// 太さで触れた場合の代表点（互いの最近接点の中点）。
Offset _closestApproachMidpoint(Offset a, Offset b, Offset c, Offset d) {
  final pairs = <List<Offset>>[
    [a, _closestPointOnSegment(a, c, d)],
    [b, _closestPointOnSegment(b, c, d)],
    [_closestPointOnSegment(c, a, b), c],
    [_closestPointOnSegment(d, a, b), d],
  ];
  var best = pairs.first;
  var bestDist = (best[0] - best[1]).distance;
  for (final pair in pairs.skip(1)) {
    final dist = (pair[0] - pair[1]).distance;
    if (dist < bestDist) {
      bestDist = dist;
      best = pair;
    }
  }
  return Offset((best[0].dx + best[1].dx) / 2, (best[0].dy + best[1].dy) / 2);
}

/// 多角形の符号なし面積（靴ひも公式）。
double polygonArea(List<Offset> points) {
  if (points.length < 3) return 0;
  double sum = 0;
  for (var i = 0; i < points.length; i++) {
    final cur = points[i];
    final nxt = points[(i + 1) % points.length];
    sum += (cur.dx * nxt.dy) - (nxt.dx * cur.dy);
  }
  return sum.abs() / 2;
}

/// 点 [p] が多角形 [polygon] の内側にあるか（偶奇規則 / ray casting）。
bool pointInPolygon(Offset p, List<Offset> polygon) {
  if (polygon.length < 3) return false;
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final pi = polygon[i];
    final pj = polygon[j];
    final intersect = ((pi.dy > p.dy) != (pj.dy > p.dy)) &&
        (p.dx <
            (pj.dx - pi.dx) * (p.dy - pi.dy) / (pj.dy - pi.dy) + pi.dx);
    if (intersect) inside = !inside;
  }
  return inside;
}

/// 多角形のバウンディングボックス（空なら Rect.zero）。
Rect boundingBox(List<Offset> polygon) {
  if (polygon.isEmpty) return Rect.zero;
  var minX = double.infinity, minY = double.infinity;
  var maxX = -double.infinity, maxY = -double.infinity;
  for (final p in polygon) {
    minX = min(minX, p.dx);
    minY = min(minY, p.dy);
    maxX = max(maxX, p.dx);
    maxY = max(maxY, p.dy);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}
