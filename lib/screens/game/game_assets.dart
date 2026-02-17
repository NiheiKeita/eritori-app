import 'package:flutter/material.dart';

const String frillImageAsset = 'assets/images/eri.png';
const String faceImageAsset = 'assets/images/face.png';
const String faceLevel2ImageAsset = 'assets/images/level2/face.PNG';

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
