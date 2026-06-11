import 'dart:typed_data';

import 'package:flutter/material.dart';

class ResultData {
  const ResultData({
    required this.levelId,
    required this.score,
    required this.success,
    required this.bestUpdated,
    required this.unlockedNext,
    required this.unlockedLevel,
    this.cutoutBytes,
  });

  final int levelId;
  final int score;
  final bool success;
  final bool bestUpdated;
  final bool unlockedNext;
  final int unlockedLevel;
  final Uint8List? cutoutBytes;
}

class ResultController extends ChangeNotifier {
  ResultController(this.data);

  ResultData data;

  void update(ResultData newData) {
    data = newData;
    notifyListeners();
  }
}
