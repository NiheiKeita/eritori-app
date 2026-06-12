import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/mask/sprite_composite.dart';
import '../../domain/models/stage.dart';

/// ステージのスプライト・マスクを読み込み・構築する（spec §6.3）。
///
/// 起動/ゲーム開始時に1度だけ実行し、結果（[SpriteComposite]）をゲーム中保持する。
class GameAssets {
  GameAssets._();

  static final Map<String, SpriteComposite> _cache = {};

  /// [stage] のスプライト合成を取得（キャッシュ）。
  static Future<SpriteComposite> load(Stage stage) async {
    final cached = _cache[stage.id];
    if (cached != null) return cached;

    final eriImage = await _loadImage(stage.eriAsset);
    final lizardImage = await _loadImage(stage.lizardAsset);
    final composite = await SpriteComposite.build(
      eriImage: eriImage,
      lizardImage: lizardImage,
    );
    _cache[stage.id] = composite;
    return composite;
  }

  static Future<ui.Image> _loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
