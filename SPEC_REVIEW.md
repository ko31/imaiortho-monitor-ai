# MonitorAI v1.5 仕様レビュー

Version: 1.0
Status: レビュー完了
対象仕様: v1.5 FINAL FREEZE

---

## 1. プロジェクト概要

MonitorAI は矯正治療向け iPhone 専用の口腔内撮影アプリ。

**目的:** AI 学習用高品質・規格化口腔内写真データセットの収集

**MonitorAI ではないもの:**
- 診断 AI
- カメラアプリ
- 遠隔医療プラットフォーム

**MonitorAI であるもの:**
- 標準化された矯正歯科画像取得プラットフォーム
- 将来の AI データセット生成基盤

---

## 2. 技術スタック

| 項目 | 仕様 |
|---|---|
| 言語 | Swift 6 |
| フレームワーク | SwiftUI |
| アーキテクチャ | MVVM + Repository Pattern + Dependency Injection + Protocol-Oriented Design |
| カメラ | AVFoundation（リアカメラのみ・Landscape のみ） |
| バックエンド | FileMaker Server 19 + FileMaker Data API（Phase 12 から使用） |

---

## 3. 対応デバイス

| 区分 | デバイス |
|---|---|
| 最低サポートデバイス | iPhone 11 |
| 主開発・検証デバイス | iPhone 15 Pro Max + Invisalign Lens |
| サポート範囲 | iPhone 11〜17（Standard / Plus / Pro / Pro Max / Air） |

---

## 4. 推奨最低対応 iOS バージョン

**推奨: iOS 17.0**

### 根拠

| 必要機能 | 最低 iOS | 重要度 |
|---|---|---|
| SwiftUI + AVFoundation 基本機能 | iOS 13 | 必須 |
| Core Haptics | iOS 13 | 必須 |
| `VNDetectContoursRequest`（開口部検出） | iOS 14 | Phase03 以降 |
| NavigationStack | iOS 16 | 推奨 |
| `@Observable` マクロ（Swift 6 MVVM） | **iOS 17** | 推奨 |

### iOS 17 を選ぶ理由

1. iPhone 11 の最大対応 iOS が 17 のため、サポート対象デバイス全機で動作する
2. `@Observable` マクロにより Swift 6 + MVVM コードが大幅にクリーンになる（旧来の `@ObservableObject`/`@StateObject` パターンが不要）
3. 仕様禁止事項「Deprecated APIs」を避けやすい
4. 医療・臨床用途のため管理下でのデバイス運用が想定され、iOS 更新要求がしやすい

---

## 5. 開発フェーズ

06_DevelopmentWorkflow.md に定義された正式フェーズ：

| Phase | 内容 | 成果物 |
|---|---|---|
| Phase 01 | Project Foundation（App Entry, DI, Navigation, Config） | アプリ起動・Build Clean |
| Phase 02 | Camera Foundation（AVCaptureSession, Live Preview, Torch, Focus） | 安定したカメラプレビュー |
| Phase 03 | Position Calibration（Grid, Center Marker, 開口部検出, 安定性検出） | Calibration 動作確認 |
| Phase 04 | Overlay Guide System（PNG Asset, Renderer, Opacity） | Overlay 表示確認 |
| Phase 05 | PTG Foundation（Visibility Scoring, Dot Logic, State Management） | PTG 動作確認 |
| Phase 06 | Voice Guidance | 音声ガイダンス動作確認 |
| Phase 07 | Haptic Feedback | 触覚フィードバック動作確認 |
| Phase 08 | Auto Capture | 自動撮影動作確認 |
| Phase 09 | Plateau Detection | Plateau 検出動作確認 |
| Phase 10 | Review Workflow | レビュー画面動作確認 |
| Phase 11 | Metadata Engine | メタデータ動作確認 |
| Phase 12 | FileMaker Integration | アップロード動作確認 |
| Phase 13 | Offline Queue | オフラインアップロード動作確認 |
| Phase 14 | Analytics | Analytics 動作確認 |
| Phase 15 | Production Validation | Release Candidate |

---

## 6. スコープ不一致（要確認）

`plan.md` と `06_DevelopmentWorkflow.md` で「Phase02」のスコープが異なる。

| ドキュメント | Phase02_CameraFoundation の内容 |
|---|---|
| plan.md | Camera Preview + 3×3 Grid + Center Marker + Torch 70% + Preview Zoom 2.5x/3.0x/4.0x |
| 06_DevelopmentWorkflow | Phase01（Project Foundation）+ Phase02（Camera Foundation）のみ |
| 06_DevelopmentWorkflow | 3×3 Grid / Center Marker / 開口部検出は Phase03 |

**plan.md の「Phase02_CameraFoundation」は spec の Phase01〜03 を合算した範囲。**

---

## 7. カメラ仕様詳細

| 項目 | 仕様 |
|---|---|
| カメラ | リアカメラのみ |
| 向き | Landscape のみ（Portrait は非対応） |
| Torch | デフォルト 70%・アダプティブ調整可・フラッシュ禁止 |
| Preview Zoom | 2.5x / 3.0x / 4.0x（プレビューのみ） |
| 保存画像 Zoom | 常に 1.0x |

### Preview Zoom の実装注意点

`AVCaptureDevice.videoZoomFactor` はプレビューと撮影の両方に影響する。

実装方針（2択）：
- **案A**: 撮影直前に `videoZoomFactor` を 1.0x にリセット → 撮影 → Zoom 値を復元
- **案B**: `AVCaptureVideoPreviewLayer` のみにスケーリングを適用し、カメラ本体の Zoom は変更しない

---

## 8. ワークフロー概要

```
Launch → Authentication → Patient Selection → Position Calibration
→ 11-Step Capture Workflow → Review Screen → Upload → Completion
```

### 11 ステップ撮影プロトコル

**Group A（Aligner ON, 5mm Open）**
- Step01: Front ON
- Step02: Right Buccal ON
- Step03: Left Buccal ON

**Group B（Aligner OFF, 5mm Open）**
- Step04: Front OFF
- Step05: Right Buccal OFF
- Step06: Left Buccal OFF
- Step07: Upper Occlusal
- Step08: Lower Occlusal

**Group C（Light Occlusion）**
- Step09: Front Occlusion
- Step10: Right Occlusion
- Step11: Left Occlusion

---

## 9. PTG（Progressive Target Guidance）

| 項目 | 仕様 |
|---|---|
| 目的 | 臨床的に有用な画像へ患者を誘導 |
| 評価基準 | 後方歯の視認性 / 咬合弓の視認性 / 臨床的有用性 |
| 評価対象外 | 頭部回転角度（主要評価指標にしない） |
| レベル | Dot1（Poor）→ Dot2 → Dot3 → Dot4（最低合格）→ Dot5（推奨）→ Dot6（理想） |
| 自動撮影条件 | PTG ≥ Dot4 AND 4秒安定 |
| Plateau 撮影条件 | PTG ≥ Dot4 AND 視認性改善なし AND 4秒安定 |

---

## 10. UI/UX 仕様

| 項目 | 仕様 |
|---|---|
| 向き | Landscape のみ（Portrait 非対応） |
| Overlay PNG 不透明度 | デフォルト 50%（範囲: 30〜70%） |
| Overlay 用途 | ポジションガイドのみ（スコアリング・診断には使用しない） |
| PTG Rail | 右側・縦配置（Dot1〜Dot6） |
| Zoom Selector | 右下配置 |
| 音声ガイダンス | デフォルト ON |
| 言語 | 日本語（ステータスメッセージ・音声ガイダンス） |

### ステータスメッセージ例
```
位置を調整してください
もう少し奥歯を見せてください
良い位置です
撮影します
```

---

## 11. アーキテクチャ詳細

### レイヤー構造

```
App Layer（MonitorAIApp.swift, AppCoordinator, DependencyContainer, AppConfiguration）
↓
Feature Layer（Authentication, PatientSelection, PositionCalibration, CaptureWorkflow, Review, Upload, Settings）
↓
ViewModel Layer（UIState管理・Workflow State・User Action Handling・Service Coordination）
↓
Service Layer（ビジネスロジック）
↓
Repository Layer（永続化・ネットワーク）
↓
API Layer（FileMaker Data API 通信）
↓
FileMaker Server 19
```

### 主要サービス一覧

| サービス | 責務 |
|---|---|
| CameraService | AVCaptureSession, Live Preview, Capture, Torch, Exposure, Focus |
| PositionCalibrationService | リトラクター開口部検出・センターオフセット計算・安定性評価 |
| OverlayGuideService | PNG Asset 読み込み・ステップ対応・不透明度制御 |
| PTGService | PTG State管理・Dot1〜6 追跡・フィードバックトリガー |
| VisibilityScoringService | 頬側・咬合面の視認性評価・スコア 0〜100 提供 |
| CaptureValidationService | Focus/Blur/Exposure/Composition/Visibility 検証 |
| AutoCaptureService | 撮影準備状態検出・安定待機・撮影トリガー |
| PlateauDetectionService | 視認性改善停滞検出・Plateau 撮影トリガー |
| VoiceGuidanceService | 音声プロンプト再生・重複防止 |
| HapticFeedbackService | 触覚イベントトリガー・PTG イベントマッピング |
| LightingService | Torch 制御・輝度モニタリング・露出ロック・アダプティブ調整 |
| MetadataService | セッション/キャプチャメタデータ収集・検証 |
| StorageService | 画像/メタデータのローカル保存・オフラインキュー永続化 |
| UploadService | FileMaker 認証・セッション/画像/メタデータアップロード・リトライ |

---

## 12. メタデータ仕様

すべての撮影画像に以下のメタデータが必須：

- PTG Data / Visibility Data / Focus Data / Blur Data / Exposure Data
- Calibration Data / Timing Data / Device Data
- ImageWidth / ImageHeight / ImageSizeBytes / ImageSHA256

**ImageSHA256 の用途:** 重複検出・整合性検証・AI エクスポートサポート

---

## 13. セキュリティ要件

**必須:**
- HTTPS / TLS 1.2+
- Bearer Token 認証
- Keychain Storage（認証情報）
- Dedicated API Account
- External Secure Storage

**禁止:**
- Guest Access
- Shared Admin Accounts
- Plain Text Credentials
- Patient Data In Logs

---

## 14. オフライン対応

- ネットワーク不在時もキャプチャワークフローは動作必須
- 失敗したアップロードはローカルキューへ格納
- 自動リトライスケジュール: 1分 → 5分 → 15分 → 1時間 → 手動リトライ

---

## 15. アップロード順序（必須）

```
Create Session → Create Capture → Create Metadata
→ Upload Full Image → Upload Thumbnail → Update Session
```

理由: メタデータは画像アップロード前に存在していなければならない

---

## 16. コード品質ルール

**禁止事項:**
- Force unwraps
- Temporary patches
- Architecture shortcuts
- Hardcoded credentials
- Unused code
- Deprecated APIs
- Global singletons

**必須事項:**
- Strong typing
- Protocol-oriented design
- Dependency injection
- Unit-testable code
- Documented public interfaces

**ビルドルール:** 実装後は必ず `xcodebuild` を実行し、エラーと警告をすべて解消する。

---

## 17. テスト要件

**カバレッジ目標:** 80%+

**ユニットテスト対象（優先）:**
PTGService / VisibilityScoringService / AutoCaptureService / PlateauDetectionService / MetadataService / UploadService

**デバイス検証必須:**
- iPhone 11
- iPhone 13
- iPhone 15 Pro Max
- Latest Supported iPhone

---

## 18. Phase 完了定義

以下をすべて満たすこと：
1. Implementation Complete
2. Build Successful（エラー・警告なし）
3. Unit Tests Pass
4. Integration Tests Pass
5. Documentation Updated
6. No Critical Issues
