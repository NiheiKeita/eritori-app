import 'dart:typed_data';

import '../../domain/models/eri.dart';

/// 整理画面へ渡す引数（spec §8.7）。満杯時、保管したい新規襟と画像を持ち込む。
class OrganizeArgs {
  const OrganizeArgs({required this.candidate, required this.png});

  /// 保管しようとしている新規襟（imagePath は未保存）。
  final Eri candidate;

  /// 新規襟の画像PNG。
  final Uint8List png;
}
