import 'package:flutter/material.dart';

import '../../storage/prefs_repository.dart';
import 'geometry.dart';
import 'level_config.dart';

enum GameStatus { idle, drawing, success, failed }

class GameController extends ChangeNotifier {
  GameController({
    required PrefsRepository prefsRepository,
  }) : _prefsRepository = prefsRepository;

  final PrefsRepository _prefsRepository;

  List<Offset> points = [];
  GameStatus status = GameStatus.idle;
  int score = 0;
  bool showTutorial = false;
  double pathLength = 0;

  Future<void> loadTutorialState() async {
    showTutorial = !(await _prefsRepository.getHasSeenTutorial());
    notifyListeners();
  }

  void start() {
    points = [];
    status = GameStatus.idle;
    score = 0;
    pathLength = 0;
    notifyListeners();
  }

  Future<void> _markTutorialSeen() async {
    if (showTutorial) {
      showTutorial = false;
      await _prefsRepository.setHasSeenTutorial(true);
      notifyListeners();
    }
  }

  void onPanStart({
    required Offset position,
    required Size size,
    required LevelConfig config,
  }) {
    if (status == GameStatus.success || status == GameStatus.failed) {
      return;
    }
    points = [position];
    status = GameStatus.drawing;
    score = 0;
    pathLength = 0;
    _markTutorialSeen();
    notifyListeners();
  }

  void onPanUpdate({
    required Offset position,
    required Size size,
    required LevelConfig config,
    required Offset swayOffset,
  }) {
    if (status != GameStatus.drawing) {
      return;
    }
    if (points.isEmpty) {
      points.add(position);
      notifyListeners();
      return;
    }
    final previous = points.last;
    points.add(position);
    pathLength += (position - previous).distance;

    if (_touchesNgArea(
      previous: previous,
      current: position,
      size: size,
      config: config,
      swayOffset: swayOffset,
    )) {
      status = GameStatus.failed;
      notifyListeners();
      return;
    }

    if (_isClosed(size: size, config: config)) {
      _completeSuccess(size: size, config: config);
    } else {
      notifyListeners();
    }
  }

  void onPanEnd({
    required Size size,
    required LevelConfig config,
  }) {
    if (status != GameStatus.drawing) {
      return;
    }
    if (points.length < config.minPoints ||
        pathLength < config.minPathLength(size)) {
      status = GameStatus.idle;
      points = [];
      notifyListeners();
      return;
    }
    if (status == GameStatus.drawing) {
      status = GameStatus.failed;
      notifyListeners();
    }
  }

  bool _isClosed({required Size size, required LevelConfig config}) {
    if (points.length < config.minPoints ||
        pathLength < config.minPathLength(size)) {
      return false;
    }
    return _hasSelfIntersection(size: size, config: config);
  }

  bool _hasSelfIntersection({
    required Size size,
    required LevelConfig config,
  }) {
    if (points.length < 4) {
      return false;
    }
    final a1 = points[points.length - 2];
    final a2 = points.last;
    final lastSegmentIndex = points.length - 2;
    for (var i = 0; i < points.length - 3; i++) {
      if (lastSegmentIndex - i < config.minIntersectionGap) {
        continue;
      }
      final b1 = points[i];
      final b2 = points[i + 1];
      if (segmentsIntersect(a1, a2, b1, b2)) {
        return true;
      }
    }
    return false;
  }

  void _completeSuccess({required Size size, required LevelConfig config}) {
    final area = polygonArea(points);
    if (area < config.minArea(size)) {
      status = GameStatus.failed;
      score = 0;
    } else {
      status = GameStatus.success;
      score = (area / 10).round();
    }
    notifyListeners();
  }

  bool _touchesNgArea({
    required Offset previous,
    required Offset current,
    required Size size,
    required LevelConfig config,
    required Offset swayOffset,
  }) {
    final circles = config.resolvedCircles(size, swayOffset);
    final body = config.resolvedBody(size, swayOffset);
    final frill = config.resolvedFrill(size, swayOffset);
    final shadow = config.resolvedShadow(size, swayOffset);
    if (lineIntersectsCircle(previous, current, body.center, body.radius)) {
      return true;
    }
    if (lineIntersectsCircle(previous, current, frill.center, frill.radius)) {
      return true;
    }
    if (lineIntersectsEllipse(
      previous,
      current,
      shadow.center,
      shadow.radiusX,
      shadow.radiusY,
    )) {
      return true;
    }
    for (final circle in circles) {
      if (lineIntersectsCircle(previous, current, circle.center, circle.radius)) {
        return true;
      }
    }
    final rects = config.resolvedRects(size, swayOffset);
    for (final rect in rects) {
      if (lineIntersectsRect(previous, current, rect)) {
        return true;
      }
    }
    return false;
  }
}
