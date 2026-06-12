import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// 効果音（spec §9.1 / §9.7）。
///
/// サウンドアセットは未提供のため、ファイルが無い場合は再生に失敗しても無視する
/// （no-op フォールバック, plan.md 仮定）。アセットを `assets/sfx/` に置けば鳴る。
enum Sfx {
  slice('sfx/slice.mp3'),
  score('sfx/score.mp3'),
  rankS('sfx/rank_s.mp3'),
  fail('sfx/fail.mp3'),
  trace('sfx/trace.mp3');

  const Sfx(this.asset);
  final String asset;
}

class AudioService {
  AudioService();

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(Sfx sfx) async {
    try {
      await _player.play(AssetSource(sfx.asset));
    } catch (e) {
      // アセット未配置などは握りつぶす（演出は任意・将来差し替え）。
      if (kDebugMode) debugPrint('AudioService: skip ${sfx.asset} ($e)');
    }
  }

  void dispose() => _player.dispose();
}
