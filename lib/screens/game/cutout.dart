import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'geometry.dart';

class CutoutResult {
  const CutoutResult({
    required this.bytes,
    required this.size,
  });

  final Uint8List bytes;
  final Size size;
}

double calculateCutoutArea({
  required List<Offset> points,
  required Offset centerPoint,
  required Size size,
}) {
  if (points.length < 3) {
    return 0;
  }
  final path = Path()..addPolygon(points, true);
  final bounds = path.getBounds();
  if (bounds.isEmpty) {
    return 0;
  }
  final polygon = polygonArea(points);
  if (path.contains(centerPoint)) {
    return (size.width * size.height) - polygon;
  }
  return polygon;
}

int calculateCutoutScore({
  required List<Offset> points,
  required Offset centerPoint,
  required Size size,
}) {
  final area =
      calculateCutoutArea(points: points, centerPoint: centerPoint, size: size);
  return (area / 10).round();
}

Future<CutoutResult?> createCutout({
  required ImageProvider background,
  required Size size,
  required List<Offset> points,
  required Offset centerPoint,
}) async {
  if (points.length < 3) {
    return null;
  }
  final path = Path()..addPolygon(points, true);
  final bounds = path.getBounds();
  if (bounds.isEmpty) {
    return null;
  }
  final isCenterInside = path.contains(centerPoint);
  final outputRect = isCenterInside
      ? Rect.fromLTWH(0, 0, size.width, size.height)
      : bounds;

  final image = await _loadImage(background);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & outputRect.size);
  if (!isCenterInside) {
    canvas.translate(-bounds.left, -bounds.top);
  }

  final boxFit = applyBoxFit(BoxFit.cover, Size(image.width.toDouble(),
      image.height.toDouble()), size);
  final fittedSource = boxFit.source;
  final fittedDestination = boxFit.destination;
  final inputSubrect = Alignment.center.inscribe(
    fittedSource,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
  );
  final outputSubrect = Alignment.center.inscribe(
    fittedDestination,
    Rect.fromLTWH(0, 0, size.width, size.height),
  );

  final clipPath = Path();
  if (isCenterInside) {
    clipPath
      ..fillType = PathFillType.evenOdd
      ..addRect(outputRect)
      ..addPath(path, Offset.zero);
  } else {
    clipPath.addPath(path, Offset.zero);
  }

  canvas.clipPath(clipPath);

  final paint = Paint();
  canvas.drawImageRect(
    image,
    inputSubrect,
    outputSubrect,
    paint,
  );

  final picture = recorder.endRecording();
  final outputImage = await picture.toImage(
    outputRect.width.ceil(),
    outputRect.height.ceil(),
  );
  final byteData = await outputImage.toByteData(
    format: ui.ImageByteFormat.png,
  );
  if (byteData == null) {
    return null;
  }
  return CutoutResult(
    bytes: byteData.buffer.asUint8List(),
    size: outputRect.size,
  );
}

Future<ui.Image> _loadImage(ImageProvider provider) async {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(const ImageConfiguration());
  late final ImageStreamListener listener;
  listener = ImageStreamListener((imageInfo, _) {
    completer.complete(imageInfo.image);
    stream.removeListener(listener);
  }, onError: (error, stack) {
    completer.completeError(error, stack);
    stream.removeListener(listener);
  });
  stream.addListener(listener);
  return completer.future;
}
