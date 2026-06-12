import 'quality.dart';

/// 襟の保管場所（spec §3.1）。襟の実体は常に1つで、location を切り替えて
/// 宝箱⇄ボードを「移動」する（コピーしない）。
enum EriLocation { chest, board }

/// 切り取った襟（spec §3.1）。
///
/// ボード上では1枚の大きなボードに自由配置する。位置 [boardX]/[boardY] は
/// ボード矩形に対する正規化座標(0..1, 中心基準)、[boardScale]/[boardRotation] は
/// 拡大率・回転(rad)、[boardZ] は重ね順（大きいほど手前）。
class Eri {
  const Eri({
    required this.id,
    required this.stageId,
    required this.stageName,
    required this.score,
    required this.captureRate,
    required this.quality,
    required this.acquiredAt,
    required this.imagePath,
    required this.isPersonalBest,
    required this.location,
    this.boardX = 0.5,
    this.boardY = 0.5,
    this.boardScale = 1.0,
    this.boardRotation = 0.0,
    this.boardZ = 0,
  });

  final String id; // UUID
  final String stageId; // "lv1"
  final String stageName; // "草原"
  final int score; // 正規化後 0..10000
  final double captureRate; // 0..1
  final Quality quality;
  final DateTime acquiredAt;
  final String imagePath; // 切り取った襟画像のローカルパス
  final bool isPersonalBest;
  final EriLocation location;

  // --- ボード配置（location == board のとき有効） ---
  final double boardX; // 0..1（ボード幅基準）
  final double boardY; // 0..1（ボード高さ基準）
  final double boardScale;
  final double boardRotation; // rad
  final int boardZ;

  Eri copyWith({
    String? imagePath,
    int? score,
    double? captureRate,
    Quality? quality,
    bool? isPersonalBest,
    EriLocation? location,
    double? boardX,
    double? boardY,
    double? boardScale,
    double? boardRotation,
    int? boardZ,
  }) {
    return Eri(
      id: id,
      stageId: stageId,
      stageName: stageName,
      score: score ?? this.score,
      captureRate: captureRate ?? this.captureRate,
      quality: quality ?? this.quality,
      acquiredAt: acquiredAt,
      imagePath: imagePath ?? this.imagePath,
      isPersonalBest: isPersonalBest ?? this.isPersonalBest,
      location: location ?? this.location,
      boardX: boardX ?? this.boardX,
      boardY: boardY ?? this.boardY,
      boardScale: boardScale ?? this.boardScale,
      boardRotation: boardRotation ?? this.boardRotation,
      boardZ: boardZ ?? this.boardZ,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stageId': stageId,
        'stageName': stageName,
        'score': score,
        'captureRate': captureRate,
        'quality': quality.name,
        'acquiredAt': acquiredAt.toIso8601String(),
        'imagePath': imagePath,
        'isPersonalBest': isPersonalBest,
        'location': location.name,
        'boardX': boardX,
        'boardY': boardY,
        'boardScale': boardScale,
        'boardRotation': boardRotation,
        'boardZ': boardZ,
      };

  factory Eri.fromJson(Map<String, dynamic> json) {
    return Eri(
      id: json['id'] as String,
      stageId: json['stageId'] as String,
      stageName: json['stageName'] as String,
      score: (json['score'] as num).toInt(),
      captureRate: (json['captureRate'] as num).toDouble(),
      quality: Quality.values.firstWhere(
        (q) => q.name == json['quality'],
        orElse: () => Quality.d,
      ),
      acquiredAt: DateTime.parse(json['acquiredAt'] as String),
      imagePath: json['imagePath'] as String,
      isPersonalBest: json['isPersonalBest'] as bool? ?? false,
      location: EriLocation.values.firstWhere(
        (l) => l.name == json['location'],
        orElse: () => EriLocation.chest,
      ),
      boardX: (json['boardX'] as num?)?.toDouble() ?? 0.5,
      boardY: (json['boardY'] as num?)?.toDouble() ?? 0.5,
      boardScale: (json['boardScale'] as num?)?.toDouble() ?? 1.0,
      boardRotation: (json['boardRotation'] as num?)?.toDouble() ?? 0.0,
      boardZ: (json['boardZ'] as num?)?.toInt() ?? 0,
    );
  }
}
