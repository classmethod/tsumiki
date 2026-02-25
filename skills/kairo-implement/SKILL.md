---
description: 分割されたタスクを順番に、またはユーザが指定したタスクを実装します。既存のTDDコマンドを活用して品質の高い実装を行います。
allowed-tools: Read, Glob, Grep, Task, Write, Edit, TodoWrite, AskUserQuestion, TaskList, TaskGet, TaskUpdate
allowed-skills: tsumiki:tdd-tasknote, tsumiki:tdd-requirements, tsumiki:tdd-testcases, tsumiki:tdd-red, tsumiki:tdd-green, tsumiki:tdd-refactor, tsumiki:tdd-verify-complete, tsumiki:direct-setup, tsumiki:direct-verify
argument-hint: "[要件名（省略可）] [TASK-ID (TASK-00001)] [--hil]"
---
あなたは実装担当者です。残タスクを調べて、指定されたコマンドを駆使して実装をしてください

# context

要件名={{requirement_name}}（引数または Claude Codeタスクから取得）
TASK-ID={{task_id}}（引数または Claude Codeタスクから取得）
hilモード={{hil}}（--hil オプション指定時は true）
defaultModel={{defaultModel}}（--model オプション）
thinkModelName={{thinkModelName}}（--think-model オプション。デフォルト: opus）
tddModelName={{tddModelName}}（--tdd-model オプション。デフォルト: sonnet）
noteModelName={{noteModelName}}（--note-model オプション。デフォルト: haiku）

コマンド選択ルール:
- thinkTaskName: thinkModelName が指定されていれば thinkModelName / defaultModel が指定されていれば defaultModel / それ以外は opus
- tddTaskName:   tddModelName が指定されていれば tddModelName / defaultModel が指定されていれば defaultModel / それ以外は sonnet
- noteTaskName:  noteModelName が指定されていれば noteModelName / defaultModel が指定されていれば defaultModel / それ以外は haiku

# step

- context の内容をまとめてユーザに宣言する
- step0 を実行する

## step0: Claude Codeタスクシステムの確認

- TaskList で未完了のタスク（pending/in_progress）を確認する
- subject が "TASK-" で始まるタスクを抽出し、各タスクを TaskGet で詳細を取得する
- metadata から requirement_name / task_file / phase / task_type を取得する
- 引数の優先順位:
  - 要件名が引数で指定されている場合: 引数の要件名を使用
  - 引数省略の場合: Claude Codeタスクの metadata から取得
  - TASK-ID が引数で指定されている場合: 引数の TASK-ID を使用
  - 引数省略の場合: blockedBy が空かつ status=pending の最初のタスクを選択
- 選択した Claude Codeタスクの ID を claude_task_id として記録する

step1 を実行する

## step1: 追加ルールの読み込み

- `docs/spec/{要件名}/note.md` が存在する場合は Read ツールで読み込む

step2 を実行する

## step2: プロジェクト文書の読み込み

以下のファイルを Read ツールで読み込む（存在するものを優先）:
- `docs/tasks/{要件名}/overview.md` または `docs/tasks/{要件名}-overview.md`
- `docs/tasks/{要件名}/TASK-{task_id}.md` または `docs/tasks/{要件名}-tasks.md`
- Claude Codeタスクの metadata に task_file がある場合はそのパスを優先使用
- 依存タスクのファイルも読み込み、実装の順序と関連性を理解する

step3 を実行する

## step3: タスクの選択と実行開始

- 選択されたタスクの詳細を表示する
- TaskUpdate でステータスを 'in_progress' に更新する
- "📌 Claude Codeタスク #{{claude_task_id}} を実行中に設定しました" を表示する

step4 を実行する

## step4: 依存関係の確認

- Claude CodeタスクのblockedByフィールドを確認する
- 依存タスクが完了しているか確認する（status=completed）
- 未完了の依存タスクがある場合は警告を表示してユーザーに確認する

step5 を実行する

## step5: 実装ディレクトリの準備

- 現在のワークスペースで必要に応じてディレクトリ構造を確認する

step6 を実行する

## step6: 実装タイプの判定

タスクの性質を分析して実装方式を決定する:
- Claude Codeタスクの metadata.task_type を参照する
- **TDD**: 新しいコンポーネント・サービス・フック等の実装、ビジネスロジック、API実装
- **DIRECT**: プロジェクト初期化、ディレクトリ作成、設定ファイル作成、依存関係インストール

step7 を実行する

## step7: 実装プロセスの実行

実装タイプに応じてプロセスファイルを Read ツールで読み込み、その step に従って実行する:

- **TDDの場合**: `skills/kairo-implement/kairo-tdd-process.md` を Read で読み込む。context に以下を設定した上でファイルの step に従って実行する:
  - thinkTaskName / tddTaskName / noteTaskName（コマンド選択ルールで解決済みの値）
  - 要件名 / TASK-ID / hilモード / claude_task_id

- **DIRECTの場合**: `skills/kairo-implement/kairo-direct-process.md` を Read で読み込む。context に以下を設定した上でファイルの step に従って実行する:
  - tddTaskName（コマンド選択ルールで解決済みの値）
  - 要件名 / TASK-ID / claude_task_id

step8 を実行する

## step8: 全体の完了確認

- TaskList で全体の進捗を確認する
- 依存関係が解消された次のタスクを提案する
- 続けて次のタスクを実装するか確認する

# rules

## エラーハンドリング

- **Claude Codeタスク関連**:
  - タスクが見つからない: 引数から要件名とTASK-IDを取得して続行
  - タスクステータス更新失敗: 警告を表示するが処理は続行
  - metadata が不完全: 引数またはタスクファイルから情報を補完
- **依存関係**:
  - 依存タスク未完了: 警告を表示し、AskUserQuestion でユーザーに確認
  - blockedBy に未完了タスクがある: 依存タスクの一覧を表示
- **実装エラー**:
  - テスト失敗: 詳細なエラー情報を表示
  - ファイル競合: バックアップを作成してから上書き

MUST: タスク開始時に TaskUpdate でステータスを 'in_progress' に更新すること
MUST: タスク完了時に TaskUpdate でステータスを 'completed' に更新すること
MUST: 引数が省略された場合は Claude Codeタスクの情報を使用すること
NEVER: 依存タスクが未完了のまま確認なしで実装を進めないこと
