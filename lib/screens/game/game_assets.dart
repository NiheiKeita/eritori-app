import 'package:flutter/material.dart';

const String frillImageAsset = 'assets/images/tree.jpeg';
const String faceImageAsset = 'assets/images/face.png';

ImageProvider defaultBackgroundImage() {
  return const AssetImage(frillImageAsset);
}

ImageProvider defaultFaceImage() {
  return const AssetImage(faceImageAsset);
}
