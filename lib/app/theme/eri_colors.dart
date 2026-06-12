import 'package:flutter/material.dart';

import '../../domain/models/stage.dart';

/// テーマ別ネオン配色（spec §9.4: 草原=緑/海=青/火山=赤/雷=黄, 高彩度+グロー）。
class EriColorSet {
  const EriColorSet({
    required this.primary,
    required this.glow,
    required this.background,
    required this.accent,
  });

  /// 主役のネオン色。
  final Color primary;

  /// なぞり線・パーティクルの発光色。
  final Color glow;

  /// 背景グラデーションの基調。
  final Color background;

  /// 強調（スコア・ランク）。
  final Color accent;

  List<Color> get backgroundGradient => [
        background,
        Color.lerp(background, Colors.black, 0.55)!,
      ];
}

/// [EriTheme] からネオン配色を引く。
class EriColors {
  EriColors._();

  static const Map<EriTheme, EriColorSet> _sets = {
    EriTheme.grassland: EriColorSet(
      primary: Color(0xFF39FF7A),
      glow: Color(0xFF7CFFA0),
      background: Color(0xFF0B3D1E),
      accent: Color(0xFFE7FF6B),
    ),
    EriTheme.sea: EriColorSet(
      primary: Color(0xFF2BD9FF),
      glow: Color(0xFF7BE9FF),
      background: Color(0xFF062B4D),
      accent: Color(0xFF6BFFF0),
    ),
    EriTheme.volcano: EriColorSet(
      primary: Color(0xFFFF3B30),
      glow: Color(0xFFFF7A5C),
      background: Color(0xFF4D0A0A),
      accent: Color(0xFFFFC24B),
    ),
    EriTheme.thunder: EriColorSet(
      primary: Color(0xFFFFE600),
      glow: Color(0xFFFFF27A),
      background: Color(0xFF332A05),
      accent: Color(0xFFFFFFFF),
    ),
  };

  static EriColorSet of(EriTheme theme) =>
      _sets[theme] ?? _sets[EriTheme.grassland]!;
}
