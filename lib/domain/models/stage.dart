/// 襟の形状タイプ（spec §3.2）。判定コードは形状で分岐しない（マスクで吸収）。
enum ShapeType { simple, ears, jaw, rotating }

/// ステージのテーマ（ネオン配色のキー）。実際の色は UI 層 (`eri_colors.dart`) で
/// このキーから引く。ドメインを Flutter の `Color` 非依存に保つため enum を用いる。
enum EriTheme { grassland, sea, volcano, thunder }

/// ステージ定義（spec §3.2）。
class Stage {
  const Stage({
    required this.id,
    required this.levelId,
    required this.name,
    required this.theme,
    required this.lizardAsset,
    required this.eriAsset,
    required this.backgroundAsset,
    required this.shape,
    required this.rotates,
    required this.rotationSpeed,
    required this.clearScore,
  });

  final String id; // "lv1"
  final int levelId; // 1
  final String name; // "草原"
  final EriTheme theme;
  final String lizardAsset; // 本体PNG（透過）
  final String eriAsset; // 襟PNG（透過）
  final String? backgroundAsset;
  final ShapeType shape;
  final bool rotates;
  final double rotationSpeed; // deg/sec（回転しないなら0）
  final int clearScore; // 解放クリア基準（正規化スコア）

  /// 解放されているか（進捗 [unlockedLevel] から算出）。
  bool isUnlocked(int unlockedLevel) => levelId <= unlockedLevel;
}
