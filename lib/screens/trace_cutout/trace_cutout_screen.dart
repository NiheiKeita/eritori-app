import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TraceCutoutScreen extends StatefulWidget {
  const TraceCutoutScreen({super.key});

  @override
  State<TraceCutoutScreen> createState() => _TraceCutoutScreenState();
}

class _TraceCutoutScreenState extends State<TraceCutoutScreen> {
  ui.Image? _image;
  List<Offset> _points = <Offset>[];
  Uint8List? _cutoutBytes;
  bool _isClosed = false;
  Size _canvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    unawaited(_loadImage());
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load('assets/images/eri.png');
    final bytes = data.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    final image = await completer.future;
    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() {
      _image = image;
    });
  }

  Rect? _computeImageRect(Size canvasSize) {
    final image = _image;
    if (image == null) {
      return null;
    }
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(BoxFit.fitWidth, imageSize, canvasSize);
    final destination = fitted.destination;
    final dx = (canvasSize.width - destination.width) / 2;
    final dy = (canvasSize.height - destination.height) / 2;
    return Rect.fromLTWH(dx, dy, destination.width, destination.height);
  }

  Offset? _toImagePoint(Offset localPosition) {
    final image = _image;
    if (image == null) {
      return null;
    }
    final imageRect = _computeImageRect(_canvasSize);
    if (imageRect == null || !imageRect.contains(localPosition)) {
      return null;
    }
    final scaleX = image.width / imageRect.width;
    final scaleY = image.height / imageRect.height;
    return Offset(
      (localPosition.dx - imageRect.left) * scaleX,
      (localPosition.dy - imageRect.top) * scaleY,
    );
  }

  Future<void> _finalizeCutout() async {
    final image = _image;
    if (image == null || _points.length < 3) {
      return;
    }
    final bounds = _boundsForPoints(_points);
    if (bounds == null || bounds.width <= 1 || bounds.height <= 1) {
      return;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final path = Path()..addPolygon(_points.map((point) {
          return Offset(point.dx - bounds.left, point.dy - bounds.top);
        }).toList(), true);

    canvas.save();
    canvas.clipPath(path);
    canvas.drawImage(image, Offset(-bounds.left, -bounds.top), Paint());
    canvas.restore();

    final picture = recorder.endRecording();
    final width = bounds.width.ceil();
    final height = bounds.height.ceil();
    final cutoutImage = await picture.toImage(width, height);
    final byteData =
        await cutoutImage.toByteData(format: ui.ImageByteFormat.png);
    cutoutImage.dispose();

    if (!mounted) {
      return;
    }

    setState(() {
      _cutoutBytes = byteData?.buffer.asUint8List();
    });
  }

  Offset? _segmentIntersectionPoint(Offset a, Offset b, Offset c, Offset d) {
    final r = b - a;
    final s = d - c;
    final rxs = _cross(r, s);
    final qpxr = _cross(c - a, r);

    if (_isZero(rxs)) {
      // Parallel or colinear; ignore for closing to avoid unstable loops.
      return null;
    }

    final t = _cross(c - a, s) / rxs;
    final u = qpxr / rxs;
    if (t < 0 || t > 1 || u < 0 || u > 1) {
      return null;
    }
    return a + r * t;
  }

  double _cross(Offset a, Offset b) {
    return a.dx * b.dy - a.dy * b.dx;
  }

  bool _isZero(double value) {
    return value.abs() < 1e-6;
  }

  Rect? _boundsForPoints(List<Offset> points) {
    if (points.isEmpty) {
      return null;
    }
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;
    for (final point in points) {
      minX = min(minX, point.dx);
      maxX = max(maxX, point.dx);
      minY = min(minY, point.dy);
      maxY = max(maxY, point.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  void _reset() {
    setState(() {
      _points = <Offset>[];
      _cutoutBytes = null;
      _isClosed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return Scaffold(
      appBar: AppBar(
        title: const Text('なぞって切り抜き'),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text('リセット'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                return GestureDetector(
                  onPanStart: (details) {
                    if (_isClosed) {
                      return;
                    }
                    final point = _toImagePoint(details.localPosition);
                    if (point == null) {
                      return;
                    }
                    setState(() {
                      _points = <Offset>[point];
                      _cutoutBytes = null;
                      _isClosed = false;
                    });
                  },
                  onPanUpdate: (details) {
                    if (_isClosed) {
                      return;
                    }
                    final point = _toImagePoint(details.localPosition);
                    if (point == null) {
                      return;
                    }
                    final nextPoints = List<Offset>.from(_points)..add(point);
                    if (nextPoints.length >= 4) {
                      final newStart = nextPoints[nextPoints.length - 2];
                      final newEnd = nextPoints.last;
                      final lastIndexToCheck = nextPoints.length - 4;
                      Offset? intersectionPoint;
                      var intersectionIndex = -1;
                      for (var i = 0; i <= lastIndexToCheck; i++) {
                        final a = nextPoints[i];
                        final b = nextPoints[i + 1];
                        final hit = _segmentIntersectionPoint(newStart, newEnd, a, b);
                        if (hit != null) {
                          intersectionPoint = hit;
                          intersectionIndex = i;
                          break;
                        }
                      }
                      if (intersectionPoint != null && intersectionIndex >= 0) {
                        final loopPoints = <Offset>[
                          intersectionPoint,
                          ...nextPoints.sublist(intersectionIndex + 1),
                        ];
                        setState(() {
                          _points = loopPoints;
                          _isClosed = true;
                        });
                        return;
                      }
                    }
                    setState(() {
                      _points = nextPoints;
                    });
                  },
                  onPanEnd: (details) {
                    if (_isClosed) {
                      unawaited(_finalizeCutout());
                    }
                  },
                  child: CustomPaint(
                    painter: TraceCutoutPainter(
                      image: image,
                      points: _points,
                      isClosed: _isClosed,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
          ),
          if (_cutoutBytes != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF2EFE6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '切り抜き結果',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Image.memory(
                      _cutoutBytes!,
                      fit: BoxFit.contain,
                      height: 160,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TraceCutoutPainter extends CustomPainter {
  TraceCutoutPainter({
    required this.image,
    required this.points,
    required this.isClosed,
  });

  final ui.Image? image;
  final List<Offset> points;
  final bool isClosed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF7F3E8),
    );

    final image = this.image;
    if (image == null) {
      return;
    }

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(BoxFit.fitWidth, imageSize, size);
    final destination = fitted.destination;
    final dx = (size.width - destination.width) / 2;
    final dy = (size.height - destination.height) / 2;
    final imageRect = Rect.fromLTWH(dx, dy, destination.width, destination.height);

    canvas.drawImageRect(
      image,
      Offset.zero & imageSize,
      imageRect,
      Paint(),
    );

    if (points.isEmpty) {
      return;
    }

    final scaleX = imageRect.width / imageSize.width;
    final scaleY = imageRect.height / imageSize.height;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final displayPoint = Offset(
        imageRect.left + point.dx * scaleX,
        imageRect.top + point.dy * scaleY,
      );
      if (i == 0) {
        path.moveTo(displayPoint.dx, displayPoint.dy);
      } else {
        path.lineTo(displayPoint.dx, displayPoint.dy);
      }
    }

    final strokePaint = Paint()
      ..color = isClosed ? const Color(0xFF1F6F75) : const Color(0xFFB84D3A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    final firstPoint = points.first;
    final displayFirst = Offset(
      imageRect.left + firstPoint.dx * scaleX,
      imageRect.top + firstPoint.dy * scaleY,
    );
    canvas.drawCircle(
      displayFirst,
      6,
      Paint()..color = const Color(0xFFB84D3A),
    );
  }

  @override
  bool shouldRepaint(covariant TraceCutoutPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.points != points ||
        oldDelegate.isClosed != isClosed;
  }
}
