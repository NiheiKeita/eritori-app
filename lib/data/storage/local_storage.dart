import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show ImageProvider, MemoryImage, FileImage;
import 'package:path_provider/path_provider.dart';

/// 襟メタ(JSON)と襟画像(PNG)のローカルファイルI/O（spec §4）。
///
/// モバイルでは documents ディレクトリ配下に `eris.json` と
/// `eri_images/<id>.png` を保存する。Web は `path_provider` / `dart:io` 非対応の
/// ため、メモリ上にフォールバックする（開発時の `flutter run -d chrome` 用。
/// リロードでデータは消える＝アプリ本来の対象はモバイル, plan.md 仮定）。
class LocalStorage {
  LocalStorage();

  // --- Web フォールバック用のメモリストア（静的: 画像参照を画面から引けるよう） ---
  static final List<Map<String, dynamic>> _memEris = [];
  static final Map<String, Uint8List> _memImages = {};

  static const String _memScheme = 'mem:';

  Directory? _docDir;

  Future<Directory> _dir() async =>
      _docDir ??= await getApplicationDocumentsDirectory();

  Future<File> _erisFile() async => File('${(await _dir()).path}/eris.json');

  Future<Directory> _imagesDir() async {
    final dir = Directory('${(await _dir()).path}/eri_images');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// 襟メタ配列を読み込む（無ければ空配列）。
  Future<List<Map<String, dynamic>>> readEris() async {
    if (kIsWeb) {
      return _memEris.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    final file = await _erisFile();
    if (!await file.exists()) return [];
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  /// 襟メタ配列を保存する。
  Future<void> writeEris(List<Map<String, dynamic>> eris) async {
    if (kIsWeb) {
      _memEris
        ..clear()
        ..addAll(eris.map((e) => Map<String, dynamic>.from(e)));
      return;
    }
    final file = await _erisFile();
    await file.writeAsString(jsonEncode(eris));
  }

  /// 襟画像(PNG)を保存し、保存先パス（Webは `mem:<id>`）を返す。
  Future<String> saveImage(String id, Uint8List png) async {
    if (kIsWeb) {
      _memImages[id] = png;
      return '$_memScheme$id';
    }
    final dir = await _imagesDir();
    final file = File('${dir.path}/$id.png');
    await file.writeAsBytes(png, flush: true);
    return file.path;
  }

  /// 襟画像を削除する（破棄時）。
  Future<void> deleteImage(String path) async {
    if (path.startsWith(_memScheme)) {
      _memImages.remove(path.substring(_memScheme.length));
      return;
    }
    if (kIsWeb) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  /// 保存パスから画像の [ImageProvider] を解決する（UI 表示用）。
  /// パスが空なら null（プレースホルダ表示）。
  static ImageProvider? imageProvider(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith(_memScheme)) {
      final bytes = _memImages[path.substring(_memScheme.length)];
      return bytes == null ? null : MemoryImage(bytes);
    }
    return FileImage(File(path));
  }
}
