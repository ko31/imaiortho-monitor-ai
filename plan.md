# MonitorAIアプリ開発プロジェクト

## ファイル構成

docs/
  CLAUDE_v1.5_FINAL_FREEZE.md
  README_v1.5_FINAL_FREEZE.md
  PROJECT_BRIEF_v1.5_FINAL_FREEZE.md
  01_MasterSpec.md
  02_Workflow_v1.5.md
  03_UI_UX_Spec.md
  04_FileMakerAPI.md
  05_Architecture.md
  06_DevelopmentWorkflow.md
  07_ReferenceImageSpec.md
  08_FileMaker_TableDesign.md REV2
  09_API_Endpoint_Spec.md REV2
  10_FileMaker_Implementation_Guide.md REV2
  11_TestPlan.md

## 作業指示

Claude Code に渡すものは、実は全部ではありません。

優先順位があります。

まず最初に渡すもの（必須）
CLAUDE_v1.5_FINAL_FREEZE.md
README_v1.5_FINAL_FREEZE.md

01_MasterSpec.md
02_Workflow_v1.5.md
03_UI_UX_Spec.md
05_Architecture.md
06_DevelopmentWorkflow.md

これだけで

Phase02_CameraFoundation

は実装できます。

Phase03から必要になるもの
07_ReferenceImageSpec.md

理由

Position Calibration
Overlay表示
Superimpose PNG

を実装するため。

FileMaker接続時に必要
04_FileMakerAPI.md

08_FileMaker_TableDesign.md REV2

08A_FileMaker_FieldDictionary_v1.5_REV2.xlsx

09_API_Endpoint_Spec.md REV2

10_FileMaker_Implementation_Guide.md REV2

これは

Phase12_FileMakerIntegration

まで不要です。

最初は渡さなくてOK。

テスト時に必要
11_TestPlan.md

これは

Phase15_ProductionValidation

まで不要。

Claude Codeへ最初に投入するフォルダ

私ならこうします。

MonitorAI_v1.5_FINAL_FREEZE

CLAUDE_v1.5_FINAL_FREEZE.md
README_v1.5_FINAL_FREEZE.md

docs/
 ├─ 01_MasterSpec.md
 ├─ 02_Workflow_v1.5.md
 ├─ 03_UI_UX_Spec.md
 ├─ 05_Architecture.md
 └─ 06_DevelopmentWorkflow.md
Claudeへの最初の指示
Read CLAUDE_v1.5_FINAL_FREEZE.md first.

After reading it, read:

README_v1.5_FINAL_FREEZE.md

01_MasterSpec.md

02_Workflow_v1.5.md

03_UI_UX_Spec.md

05_Architecture.md

06_DevelopmentWorkflow.md

Implement only:

Phase02_CameraFoundation

Do not implement:

FileMaker
PTG
Upload
Metadata
Offline Queue

Run xcodebuild after implementation.

Fix all build errors.

Report in Japanese.
あなたの場合のおすすめ

今の段階なら Claude Code に渡すのは

CLAUDE_v1.5_FINAL_FREEZE.md
README_v1.5_FINAL_FREEZE.md
01_MasterSpec.md
02_Workflow_v1.5.md
03_UI_UX_Spec.md
05_Architecture.md
06_DevelopmentWorkflow.md

の 7ファイルだけ にしてください。

いきなり15ファイル全部渡すと、Claude Code が FileMaker や API 実装まで先走る可能性があります。

まずは

Phase02_CameraFoundation

だけを完成させて、

Landscape表示
カメラプレビュー
3×3グリッド
Center Marker
Torch 70%
Preview Zoom 2.5x/3.0x/4.0x

を実機（iPhone 15 Pro Max + Invisalign Lens）で確認するのが最も効率的です。


