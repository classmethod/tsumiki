---
description: TDD開発のコンテキスト情報を収集してノートにまとめます。技術スタック、追加ルール、関連ファイルの情報を整理します。
allowed-tools: Read, Glob, Grep, Task, Write, TodoWrite, Edit
argument-hint: "[要件名] [TASK-ID]"
---
TDD開発の前にコンテキスト情報を収集し、開発に必要な情報をノートファイルにまとめます。

# context

出力ディレクトリ="./docs/implements"
機能名={{feature_name}}
タスクID={{task_id}}
要件名={{requirement_name}}
収集情報=[]
noteファイル="./docs/implements/{要件名}/{{task_id}}/note.md"

# step

- $ARGUMENTS がない場合、「引数に要件名とTASK-IDを指定してください（例: ユーザー認証機能 TASK-0001）」と言って終了する
- {{noteファイル}} が既にある場合、「すでに完了しています」といって終了する
- 開発コンテキストを収集する：
   **追加ルールの読み込み**
   - `AGENTS.md` ファイルが存在する場合は読み込み
   - `./docs/rule` ディレクトリが存在する場合は読み込み
   - `./docs/rule/tdd` ディレクトリが存在する場合は、サブディレクトリを含む全ファイルを読み込み
     - `./docs/rule/tdd/red/`, `./docs/rule/tdd/green/`, `./docs/rule/tdd/refactor/`, `./docs/rule/tdd/testcases/`, `./docs/rule/tdd/verify-complete/` など全て対象
   - 各ディレクトリ内のすべてのファイルを読み込み、追加ルールとして適用

  **Task tool (subagent_type: Explore, thoroughness: quick) を使用して実装関連情報を探索**
    - `./docs/spec/{要件名}-requirements.md`: 統合機能要件と関連文書へ
    - `./docs/spec/{要件名}-user-stories.md`: 詳細なユーザストーリー
    - `./docs/spec/{要件名}-acceptance-criteria.md`: 受け入れ基準とテスト項目
    - `./docs/spec/{要件名}-*.md`: 受け入れ基準とテスト項目
   - 既存の類似機能やユーティリティ関数を探索
   - 実装パターンやアーキテクチャガイドラインを特定
   - 依存関係やインポートパスを確認
   - **テスト関連情報の探索**（後続フェーズで再探索不要にするため）:
     - テストフレームワークの設定ファイル（jest.config.js, playwright.config.js等）
     - 既存のテストファイルのパターンとディレクトリ構成
     - テストユーティリティやモック設定
     - E2Eテスト設定（UIタスクの場合）

  **関連ファイルを直接読み込み**
   - `./docs/implements/{要件名}/{{task_id}}/*.md` - taskに関係する全てのファイルを読み込み
   - 関連する設計文書やタスクファイルも必要に応じて読み込み

- 収集した情報を整理して {{noteファイル}} に保存する
  - **重要**: ノートファイル内のすべてのファイルパスは、プロジェクトルートからの相対パスで記載すること（絶対パスは使用しない）

# rules

## ファイル名のルール

### 出力ファイルのパス形式
- `./docs/implements/{要件名}/{{task_id}}/note.md`
- 例: `docs/implements/user-auth/task-0001/note.md`

### ファイル名の命名規則
- 機能名を簡潔な英語に変換する
- ケバブケース（kebab-case）を使用
- 最大50文字程度に収める
- 例:
  - "ユーザー認証機能" → "user-auth"
  - "データエクスポート機能" → "data-export"
  - "パスワードリセット機能" → "password-reset"

## ファイルパスの記載ルール（必須）

- **プロジェクトルートを基準とした相対パスを使用する**
- **絶対パス（フルパス）は絶対に記載しない**
- **ディレクトリパスも相対パスで記載する**
- 例:
  - ❌ `/Users/username/projects/myapp/src/utils/helper.ts`
  - ❌ `/Users/username/projects/myapp/docs/spec/`
  - ✅ `src/utils/helper.ts`
  - ✅ `docs/spec/`
  - ✅ `backend/app/main.py`
  - ✅ `frontend/src/components/`

# output_format

## ノート構成

### 1. 技術スタック
- 使用技術・フレームワーク
- アーキテクチャパターン
- 参照元: [相対ファイルパス]

### 2. 開発ルール
- プロジェクト固有のルール
- コーディング規約
- 参照元: [相対ファイルパス一覧]

### 3. 関連実装
- 類似機能の実装例
- 参考パターン
- 参照元: [相対ファイルパス一覧]

### 4. 設計文書
- アーキテクチャ・API仕様
- データモデル
- 参照元: [相対ファイルパス一覧]

### 5. テスト関連情報
- テストフレームワーク・設定ファイルのパス
- 既存テストのディレクトリ構成・命名パターン
- テストユーティリティ・モック設定
- E2Eテスト設定（該当する場合）
- 参照元: [相対ファイルパス一覧]

### 6. 注意事項
- 技術的制約
- セキュリティ・パフォーマンス要件
- 参照元: [相対ファイルパス]

---

## 🚨 重要な記載ルール

**すべてのファイルパス・ディレクトリパスは、プロジェクトルートからの相対パスで記載すること**

### 相対パス記載の例

✅ **正しい記載例**:
```
- 参照元: docs/tech-stack.md
- 参照元: backend/app/main.py
- 参照元: frontend/src/components/TodoList.tsx
- ディレクトリ: docs/spec/personal-todo-app/
```

❌ **誤った記載例（絶対に避ける）**:
```
- 参照元: /Users/username/projects/ai/test02/docs/tech-stack.md
- 参照元: /Users/username/projects/ai/test02/backend/app/main.py
- ディレクトリ: /Users/username/projects/ai/test02/docs/spec/
```

### 実装時の注意

1. **Read ツールで読み込むとき**: 絶対パスを使用して読み込む
2. **ノートファイルに記載するとき**: 必ず相対パスに変換して記載する
3. **ディレクトリパスも同様**: `/Users/.../docs/spec/` → `docs/spec/`
