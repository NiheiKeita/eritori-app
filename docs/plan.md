# エリトリ 実装計画 / アーキテクチャ判断

仕様: [spec.md](./spec.md)

## 全面再構築の方針

既存 `lib/screens/*`（円・楕円・矩形による簡易マスク判定）は破棄し、仕様が要求する
**PNGアルファchベースのピクセルマスク判定 + ローカル座標逆行列変換** に置き換える。

ただし**既存プロジェクトの規約は踏襲**する:
- ルーティング: `go_router`
- DI: `AppScope`(InheritedWidget) によるコンストラクタインジェクション
- 画面構成: Container(状態接続) / Presentation(純粋UI) / Controller(状態) の3分割
- Lint: single quote 強制（`prefer_single_quotes: error`）

## ディレクトリ構成（採用）

```
lib/
  main.dart                     # 起動・DI組み立て
  app/
    app.dart                    # MaterialApp.router
    router.dart                 # go_router
    theme/
      app_theme.dart            # テーマ・タイポ
      eri_colors.dart           # 草原/海/火山/雷 ネオン配色
  domain/
    models/ eri.dart stage.dart quality.dart
    scoring/ stroke.dart polygon_math.dart score_calculator.dart
    mask/ pixel_mask.dart       # ui.Image→アルファバッファ→isOpaqueAt
    config/ game_config.dart    # 全数値外出し(JSON読込対応)
  data/
    repositories/ eri_repository.dart progress_repository.dart
    storage/ local_storage.dart # JSON+画像I/O (path_provider)
  features/
    home/ game/ result/ fail/ chest/ board/ organize/ tutorial/ settings/
  shared/
    widgets/ effects/ audio/
```

## 重要な設計判断

1. **ドメイン純粋化**: `polygon_math`(自己交差・面積・point-in-polygon)と
   `score_calculator`(捕捉率→正規化→品質)は Flutter UI 非依存の純粋関数。`dart:ui` の
   `Offset` は使わず軽量 `Vec2`(自前 or `math`) を用い、テスト容易にする。
   → 判断: `Offset` は `dart:ui` だが Flutter test で利用可能・既存コードでも利用済みのため
     `Offset` を採用しつつ Widget 非依存に保つ。

2. **マスク判定**: 起動時に本体PNG/襟PNGを `ui.Image` 化 → `toByteData(rgba)` で
   `Uint8List` を保持。`isOpaqueAt(localPx)` はバッファ参照で O(1)。判定解像度は長辺512pxへ縮小。

3. **座標系**: `Matrix4 spriteTransform`（画面←ローカル）。指先は
   `spriteTransform.clone()..invert()` で `transform3`。回転は `spriteTransform` に回転を
   合成するだけで判定コードは共通。

4. **移動モデル**: `Eri.location` を chest/board で切替。`EriRepository` は move 操作のみ提供し
   コピーしない。

5. **画像生成**: ループ多角形を `Path` にして `Canvas.clipPath` → 襟スプライト描画 →
   `PictureRecorder`→`toImage`→PNG。長辺512pxにスケール。

6. **演出**: `AnimationController` ベース。パーティクルは自前 `CustomPainter`。
   `game_config` にスロー時間/シェイク強度などを集約。サウンドは `audioplayers`、
   アセット未提供時は no-op フォールバック。

## 仮定（アセット未提供分はプレースホルダ）

- トカゲ本体PNG/襟PNGは Lv1 用に `assets/images/face.png`・`assets/images/eri.png` を流用。
  Lv2〜4 は未提供のためプレースホルダ（同アセット+テーマ色変更）で進め、差し替え可能にする。
- サウンドアセット未提供 → 再生は no-op（パス定義のみ）。
- プレイヤー名はローカル任意入力（未設定可）。
- 容量拡張(Lv5/10/20)は config 定義のみ。現状 Lv4 まで。

## 実装フェーズ（spec §12 準拠）

1. ドメイン層（polygon_math/score_calculator/models/config）+ 単体テスト ← 最優先
2. マスク(pixel_mask) + ローカル座標変換
3. ゲーム画面（描画/ジェスチャ/判定）静止レベル → 一周成立
4. 回転レベル（spriteTransformに回転を入れるだけ）
5. 切り取り画像生成 → リザルト/失敗画面
6. 永続化 → 宝箱 → エリボード(移動) → 整理画面
7. 共有画像生成 → 共有シート
8. チュートリアル + 設定
9. 演出・サウンド(juice)
10. flutter analyze / test で検証、config 実プレイ調整

各フェーズで「動作する状態」を保ちながら積み上げる。
