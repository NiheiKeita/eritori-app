# エリトリ (Eritori)

エリマキトカゲの「襟」を指でなぞって切り取るカジュアルゲーム。顔に触れずに襟を大きく
えぐり取り、良い襟を集めてエリボードに展示・SNS共有する。縦持ち専用。

## ドキュメント

- 仕様書: [docs/spec.md](docs/spec.md)
- 実装計画・アーキテクチャ判断・仮定: [docs/plan.md](docs/plan.md)

## アーキテクチャ概要

判定・スコアはすべて **襟スプライトのローカル座標（=PNGアルファchマスクのピクセル空間）**
で行い、回転レベルも変換行列に回転を入れるだけで同一コードで動く。

```
lib/
  domain/      # 純粋ロジック（UI非依存・単体テスト対象）
    scoring/   polygon_math, score_calculator, stroke
    mask/      pixel_mask（isOpaqueAt/countOpaqueInside）, sprite_composite
    models/    eri, stage, quality   config/  game_config, stage_catalog
  data/        repositories（eri/progress, 移動モデル）, storage（path_provider I/O）
  features/    game, result, fail, home, chest, board, organize, tutorial, settings
  shared/      widgets, effects（slice flash/particles）, audio, share
  app/         router(go_router), app, theme（ネオン配色）   state/  progress_controller
```

- 状態管理: `AppScope`(InheritedWidget) による DI + Container/Presentation/Controller
- 永続化: 進捗=shared_preferences / 襟メタ=eris.json / 襟画像=PNGファイル

## 検証

```
flutter test      # ドメイン+マスクの単体テスト（26 passing）
flutter analyze   # No issues
flutter build web # 全体コンパイル確認
```

## 調整ポイント

クリア基準・品質閾値・回転速度・容量・演出時間は
[lib/domain/config/game_config.dart](lib/domain/config/game_config.dart) と
[lib/domain/config/stage_catalog.dart](lib/domain/config/stage_catalog.dart) に集約。

## 未提供アセットの扱い

トカゲ/襟PNGは Lv1 用（face.png / eri.png）を流用し、Lv2〜4 はテーマ色で差別化した
プレースホルダ。サウンドは `assets/sfx/` に置けば鳴る no-op フォールバック。詳細は plan.md。
