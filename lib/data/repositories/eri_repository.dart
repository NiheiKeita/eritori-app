import 'package:flutter/foundation.dart';

import '../../domain/config/game_config.dart';
import '../../domain/models/eri.dart';
import '../storage/local_storage.dart';

/// 襟の保存/読込/移動を担うリポジトリ（spec §3.1 / §4 / §8.5-8.7）。
///
/// 「移動」モデル：襟の実体は常に1つで、[move] は location を切り替えるのみ。
/// コピーはしない。
class EriRepository extends ChangeNotifier {
  EriRepository(this._storage);

  final LocalStorage _storage;
  final List<Eri> _eris = [];

  List<Eri> get all => List.unmodifiable(_eris);
  List<Eri> get inChest =>
      _eris.where((e) => e.location == EriLocation.chest).toList();
  List<Eri> get onBoard =>
      _eris.where((e) => e.location == EriLocation.board).toList();

  int get chestCapacity => GameConfig.chestBaseCapacity;
  bool get isChestFull => inChest.length >= chestCapacity;
  // ボードは1枚の大きなキャンバスに自由配置するため枚数制限なし（spec §8.6）。

  Future<void> load() async {
    final raw = await _storage.readEris();
    _eris
      ..clear()
      ..addAll(raw.map(Eri.fromJson));
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.writeEris(_eris.map((e) => e.toJson()).toList());
  }

  /// 確定済みの襟（画像PNG付き）を宝箱に追加する。画像をファイル保存しパスを持たせる。
  /// 宝箱が満杯のときは追加せず null を返す（呼び出し側が整理画面へ誘導）。
  Future<Eri?> addToChest(Eri eri, Uint8List png) async {
    if (isChestFull) return null;
    final path = await _storage.saveImage(eri.id, png);
    final withPath = Eri(
      id: eri.id,
      stageId: eri.stageId,
      stageName: eri.stageName,
      score: eri.score,
      captureRate: eri.captureRate,
      quality: eri.quality,
      acquiredAt: eri.acquiredAt,
      imagePath: path,
      isPersonalBest: eri.isPersonalBest,
      location: EriLocation.chest,
    );
    _eris.add(withPath);
    await _persist();
    notifyListeners();
    return withPath;
  }

  /// 既存の宝箱の襟 [removeId] を破棄し、新しい襟 [eri] を宝箱に入れる（整理画面の入れ替え）。
  Future<Eri> swapInChest(String removeId, Eri eri, Uint8List png) async {
    await remove(removeId);
    final path = await _storage.saveImage(eri.id, png);
    final withPath = eri.copyWith(
      imagePath: path,
      location: EriLocation.chest,
    );
    _eris.add(withPath);
    await _persist();
    notifyListeners();
    return withPath;
  }

  int get _topZ =>
      onBoard.fold<int>(0, (m, e) => e.boardZ > m ? e.boardZ : m);

  /// 宝箱⇄ボードの「移動」。location を切り替える（実体は1つ）。
  /// ボードへ移すときは中央付近に置き、最前面の重ね順を与える。
  Future<void> move(String id, EriLocation to) async {
    final index = _eris.indexWhere((e) => e.id == id);
    if (index < 0) return;
    if (to == EriLocation.board) {
      _eris[index] = _eris[index].copyWith(
        location: to,
        boardX: 0.5,
        boardY: 0.5,
        boardZ: _topZ + 1,
      );
    } else {
      _eris[index] = _eris[index].copyWith(location: to);
    }
    await _persist();
    notifyListeners();
  }

  /// ボード上の配置（位置・拡大・回転）を更新する（spec §8.6 自由配置）。
  Future<void> updateBoardPlacement(
    String id, {
    double? boardX,
    double? boardY,
    double? boardScale,
    double? boardRotation,
  }) async {
    final index = _eris.indexWhere((e) => e.id == id);
    if (index < 0) return;
    _eris[index] = _eris[index].copyWith(
      boardX: boardX,
      boardY: boardY,
      boardScale: boardScale,
      boardRotation: boardRotation,
    );
    await _persist();
    notifyListeners();
  }

  /// 指定の襟を最前面へ（重なり時の操作対象を手前に出す）。
  Future<void> bringToFront(String id) async {
    final index = _eris.indexWhere((e) => e.id == id);
    if (index < 0) return;
    _eris[index] = _eris[index].copyWith(boardZ: _topZ + 1);
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    final index = _eris.indexWhere((e) => e.id == id);
    if (index < 0) return;
    await _storage.deleteImage(_eris[index].imagePath);
    _eris.removeAt(index);
    await _persist();
    notifyListeners();
  }
}
