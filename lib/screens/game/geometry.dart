import 'dart:math';

import 'package:flutter/material.dart';

double polygonArea(List<Offset> points) {
  if (points.length < 3) {
    return 0;
  }
  double sum = 0;
  for (var i = 0; i < points.length; i++) {
    final current = points[i];
    final next = points[(i + 1) % points.length];
    sum += (current.dx * next.dy) - (next.dx * current.dy);
  }
  return sum.abs() / 2;
}

bool lineIntersectsCircle(
  Offset a,
  Offset b,
  Offset center,
  double radius,
) {
  final ab = b - a;
  final ac = center - a;
  final abLenSquared = ab.dx * ab.dx + ab.dy * ab.dy;
  if (abLenSquared == 0) {
    return (center - a).distance <= radius;
  }
  final t = ((ac.dx * ab.dx) + (ac.dy * ab.dy)) / abLenSquared;
  final clampedT = t.clamp(0.0, 1.0);
  final closest = Offset(
    a.dx + ab.dx * clampedT,
    a.dy + ab.dy * clampedT,
  );
  return (center - closest).distance <= radius;
}

bool lineIntersectsEllipse(
  Offset a,
  Offset b,
  Offset center,
  double radiusX,
  double radiusY,
) {
  if (radiusX == 0 || radiusY == 0) {
    return false;
  }
  Offset normalize(Offset p) {
    return Offset(
      (p.dx - center.dx) / radiusX,
      (p.dy - center.dy) / radiusY,
    );
  }

  final na = normalize(a);
  final nb = normalize(b);
  return lineIntersectsCircle(na, nb, Offset.zero, 1);
}

bool lineIntersectsRect(Offset a, Offset b, Rect rect) {
  if (rect.contains(a) || rect.contains(b)) {
    return true;
  }

  final topLeft = rect.topLeft;
  final topRight = rect.topRight;
  final bottomLeft = rect.bottomLeft;
  final bottomRight = rect.bottomRight;

  return segmentsIntersect(a, b, topLeft, topRight) ||
      segmentsIntersect(a, b, topRight, bottomRight) ||
      segmentsIntersect(a, b, bottomRight, bottomLeft) ||
      segmentsIntersect(a, b, bottomLeft, topLeft);
}

bool segmentsIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
  double cross(Offset a, Offset b, Offset c) {
    return (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
  }

  bool onSegment(Offset a, Offset b, Offset c) {
    return min(a.dx, b.dx) <= c.dx &&
        c.dx <= max(a.dx, b.dx) &&
        min(a.dy, b.dy) <= c.dy &&
        c.dy <= max(a.dy, b.dy);
  }

  final d1 = cross(p1, p2, p3);
  final d2 = cross(p1, p2, p4);
  final d3 = cross(p3, p4, p1);
  final d4 = cross(p3, p4, p2);

  if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
    return true;
  }

  if (d1 == 0 && onSegment(p1, p2, p3)) {
    return true;
  }
  if (d2 == 0 && onSegment(p1, p2, p4)) {
    return true;
  }
  if (d3 == 0 && onSegment(p3, p4, p1)) {
    return true;
  }
  if (d4 == 0 && onSegment(p3, p4, p2)) {
    return true;
  }

  return false;
}
