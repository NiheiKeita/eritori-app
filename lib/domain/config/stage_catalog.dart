import '../models/stage.dart';

/// ステージ定義の一覧（spec §7.1 のクリア基準を反映）。
///
/// クリア基準・回転速度はバランス調整対象。ここに集約する。
/// Lv2〜4 のアセットは未提供のため、現状は Lv1 アセットをプレースホルダとして流用し
/// テーマ色で差別化する（差し替え可能, plan.md 仮定）。
class StageCatalog {
  StageCatalog._();

  static const String _lizard = 'assets/images/face.png';
  static const String _eri = 'assets/images/eri.png';

  static const List<Stage> stages = [
    Stage(
      id: 'lv1',
      levelId: 1,
      name: '草原',
      theme: EriTheme.grassland,
      lizardAsset: _lizard,
      eriAsset: _eri,
      backgroundAsset: 'assets/images/tree_bk.jpeg',
      shape: ShapeType.simple,
      rotates: false,
      rotationSpeed: 0,
      clearScore: 7000,
    ),
    Stage(
      id: 'lv2',
      levelId: 2,
      name: '海',
      theme: EriTheme.sea,
      lizardAsset: _lizard,
      eriAsset: _eri,
      backgroundAsset: null,
      shape: ShapeType.ears,
      rotates: false,
      rotationSpeed: 0,
      clearScore: 7500,
    ),
    Stage(
      id: 'lv3',
      levelId: 3,
      name: '火山',
      theme: EriTheme.volcano,
      lizardAsset: _lizard,
      eriAsset: _eri,
      backgroundAsset: null,
      shape: ShapeType.jaw,
      rotates: false,
      rotationSpeed: 0,
      clearScore: 8000,
    ),
    Stage(
      id: 'lv4',
      levelId: 4,
      name: '雷',
      theme: EriTheme.thunder,
      lizardAsset: _lizard,
      eriAsset: _eri,
      backgroundAsset: null,
      shape: ShapeType.rotating,
      rotates: true,
      rotationSpeed: 36, // deg/sec（中速, 暫定）
      clearScore: 7500,
    ),
  ];

  static int get maxLevel => stages.length;

  static Stage byLevel(int levelId) => stages.firstWhere(
        (s) => s.levelId == levelId,
        orElse: () => stages.first,
      );

  static Stage byId(String id) => stages.firstWhere(
        (s) => s.id == id,
        orElse: () => stages.first,
      );
}
