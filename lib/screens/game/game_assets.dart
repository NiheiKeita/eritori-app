import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

Uint8List transparentPngBytes() {
  const base64Data =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIW2P8'
      'z/C/HwAFgwJ/lxZl3wAAAABJRU5ErkJggg==';
  return base64Decode(base64Data);
}

ImageProvider defaultBackgroundImage() {
  return MemoryImage(transparentPngBytes());
}
