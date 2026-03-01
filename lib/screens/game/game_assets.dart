import 'package:flutter/material.dart';

import 'level_config.dart';

const String frillImageAsset = 'assets/images/eri.png';
const String faceImageAsset = 'assets/images/face.png';
const String faceLevel2ImageAsset = 'assets/images/level2/face.PNG';
const BoxFit gameFrillFit = BoxFit.contain;

ImageProvider defaultBackgroundImage() {
  return const AssetImage(frillImageAsset);
}

ImageProvider defaultFaceImage() {
  return const AssetImage(faceImageAsset);
}

ImageProvider faceImageForLevel(int levelId) {
  if (levelId == 2) {
    return const AssetImage(faceLevel2ImageAsset);
  }
  return const AssetImage(faceImageAsset);
}

Rect frillImageRect({
  required Size size,
  required LevelConfig config,
  required Offset swayOffset,
}) {
  final frill = config.resolvedFrill(size, swayOffset);
  return Rect.fromCenter(
    center: frill.center,
    width: frill.radius * 2 * config.frillDisplayScale,
    height: frill.radius * 2 * config.frillDisplayScale,
  );
}

Rect faceImageRect({
  required Size size,
  required LevelConfig config,
  required Offset swayOffset,
}) {
  final face = config.resolvedBody(size, swayOffset);
  final scaledRadius = face.radius * config.faceScale;
  return Rect.fromCenter(
    center: config.resolvedFaceCenter(size, swayOffset),
    width: scaledRadius * 2,
    height: scaledRadius * 2,
  );
}
