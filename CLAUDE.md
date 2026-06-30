# MonitorAI — Claude Code 開発ルール

## プロジェクト概要

矯正歯科向け iPhone 専用口腔内撮影アプリ。AI 学習データセット収集基盤。
MonitorAI は診断を行わない。「高品質で規格化された口腔内写真の収集」に特化する。

詳細仕様: `docs/` 以下の PDF 参照。レビューサマリー: `SPEC_REVIEW.md`

---

## 技術スタック

| 項目 | 仕様 |
|---|---|
| 言語 | Swift 6（strict concurrency 必須） |
| UI | SwiftUI + `@Observable` マクロ（`@ObservableObject` は使わない） |
| アーキテクチャ | MVVM + Repository Pattern + Dependency Injection + Protocol-Oriented Design |
| カメラ | AVFoundation（リアカメラのみ・Landscape のみ） |
| Navigation | NavigationStack |
| 最低 iOS | **iOS 17.0** |
| 対象デバイス | iPhone 11〜17（iPhone 15 Pro Max が主開発機） |
| バックエンド | FileMaker Server 19（Phase 12 まで不要） |

---

## アーキテクチャルール

```
App Layer（MonitorAIApp, AppCoordinator, DependencyContainer, AppConfiguration）
Feature Layer（各画面・フロー）
ViewModel Layer（UIState・Workflow State・User Action・Service Coordination）
Service Layer（ビジネスロジック）
Repository Layer（永続化・ネットワーク）
API Layer（FileMaker Data API）
FileMaker Server 19
```

- すべての Service・Repository は Protocol で定義し、DI で注入する
- Global singleton 禁止
- ViewModel から直接 Repository を呼ばない（Service 経由）

---

## 禁止事項（コード品質）

- `!` による Force unwrap
- `try!` / `as!`
- Deprecated API の使用
- Global singleton（`shared` インスタンスを Service/Repository に使わない）
- Hardcoded credentials
- 未使用コード（unused variables/functions）
- Temporary patches・Architecture shortcuts
- `@ObservableObject` / `@StateObject`（`@Observable` を使う）

---

## カメラ仕様（実装上の重要制約）

| 項目 | 仕様 |
|---|---|
| 向き | **Landscape のみ**（Portrait 非対応） |
| Torch | デフォルト 70%・アダプティブ調整可・**フラッシュ禁止** |
| Preview Zoom | 2.5x / 3.0x / 4.0x（プレビュー表示のみ） |
| 保存画像 Zoom | **常に 1.0x**（`videoZoomFactor` は撮影前に必ず 1.0 にリセット） |
| フォーカス | 手動フォーカス対応 |

### Preview Zoom 実装注意

`AVCaptureDevice.videoZoomFactor` を変更するとプレビューと撮影の両方に影響する。
実装案A（推奨）: 撮影直前に `videoZoomFactor = 1.0` → 撮影 → 元の値に復元

---

## UI/UX ルール

- Overlay PNG 不透明度: デフォルト 50%（範囲 30〜70%）
- PTG Rail: 右側・縦配置（Dot1〜Dot6）
- Zoom Selector: 右下配置
- 音声ガイダンス: デフォルト ON
- ステータスメッセージ・音声ガイダンスは**日本語**

---

## フェーズ構成と現在のスコープ

実装は `06_DevelopmentWorkflow.md.pdf` のフェーズ定義に従う。

| Phase | 内容 |
|---|---|
| **Phase 01** | **Project Foundation（App Entry, DI, Navigation, Config）** |
| **Phase 02** | **Camera Foundation（AVCaptureSession, Live Preview, Torch, Focus, 3×3 Grid, Center Marker, Preview Zoom）** |
| Phase 03 | Position Calibration（Opening Detection / 開口部検出, Stability Detection） |
| Phase 04 | Overlay Guide System |
| Phase 05 | PTG Foundation |
| Phase 06〜09 | Voice / Haptic / Auto Capture / Plateau Detection |
| Phase 10〜11 | Review / Metadata Engine |
| Phase 12 | FileMaker Integration |
| Phase 13 | Offline Queue |
| Phase 14〜15 | Analytics / Production Validation |

### 現在実装すべき範囲

指示があるまで **Phase 01 + Phase 02 のみ** を実装する。

**Phase 02 で実装しないもの:**
- FileMaker 連携
- PTG
- Upload
- Metadata
- Offline Queue
- Opening Detection / 開口部検出（Phase 03 以降）

---

## ビルドルール

実装後は必ず以下を実行し、**エラー・警告がゼロ** であることを確認してから報告する:

```bash
xcodebuild -scheme MonitorAI -destination 'generic/platform=iOS' build
```

警告も放置しない。Swift 6 の concurrency 警告もすべて解消すること。

---

## PTG システム（Phase 05 以降）

| Dot | 評価 |
|---|---|
| Dot1 | Poor |
| Dot2 | Improving |
| Dot3 | Acceptable |
| Dot4 | 最低合格（自動撮影の閾値） |
| Dot5 | 推奨 |
| Dot6 | 理想 |

自動撮影条件: PTG ≥ Dot4 AND 4秒安定

---

## セキュリティルール

- 認証情報は Keychain に保存（UserDefaults・ログ・コード内に書かない）
- HTTPS / TLS 1.2+ 必須
- Bearer Token 認証
- 患者データをログに出力しない

---

## 参照ドキュメント（優先順）

1. `docs/CLAUDE_v1.5_FINAL_FREEZE.md REV2.pdf` — 開発憲法
2. `docs/README_v1.5_FINAL_FREEZE REV2.pdf` — 概要
3. `docs/01_MasterSpec.md.pdf` — 設計哲学
4. `docs/02_Workflow_v1.5.md.pdf` — 撮影ワークフロー
5. `docs/03_UI_UX_Spec.md.pdf` — UI/UX 仕様
6. `docs/05_Architecture.md.pdf` — アーキテクチャ詳細
7. `docs/06_DevelopmentWorkflow.md.pdf` — フェーズ定義

Phase 12 以降: `04_FileMakerAPI.md` / `08〜10` 系 PDF
Phase 03 以降: `07_ReferenceImageSpec.md`
