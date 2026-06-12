import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// エリボードを画像化して OS 共有シートへ渡す（spec §10）。
///
/// `RepaintBoundary` を `ui.Image` 化 → PNG 一時ファイル → `share_plus`。
/// サーバー保存なし。端末内画像生成のみで完結する。
class BoardSharer {
  BoardSharer._();

  static Future<void> share(GlobalKey boundaryKey, {String? text}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return;

    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();
    final shareText = text ?? 'エリトリのコレクション見て！ #エリトリ';

    // Web は一時ディレクトリ非対応のためバイト列を直接共有する。
    final XFile xfile = kIsWeb
        ? XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: 'eritori_board.png',
          )
        : await _writeTempFile(bytes);

    await SharePlus.instance.share(
      ShareParams(files: [xfile], text: shareText),
    );
  }

  static Future<XFile> _writeTempFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/eritori_board.png');
    await file.writeAsBytes(bytes, flush: true);
    return XFile(file.path);
  }
}
