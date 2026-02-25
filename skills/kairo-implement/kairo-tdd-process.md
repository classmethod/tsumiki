TDDプロセスを実行します。tasknote → requirements → testcases → red → green → refactor → verify-complete の順に各フェーズを個別Taskで実行します。

# context

thinkTaskName={{thinkTaskName}}
tddTaskName={{tddTaskName}}
noteTaskName={{noteTaskName}}
要件名={{requirement_name}}
TASK-ID={{task_id}}
hilモード={{hil}}
claude_task_id={{claude_task_id}}

# step

- context の内容を確認する
- step-a を実行する

## step-a: コンテキスト準備

以下の Task を実行する:

```
@Task tool (subagent_type: general-purpose, model: {{noteTaskName}}) /tsumiki:tdd-tasknote {{要件名}} {{TASK-ID}}
```

完了したら step-b を実行する

## step-b: 要件定義

以下の Task を実行する:

```
@Task tool (subagent_type: general-purpose, model: {{thinkTaskName}}) /tsumiki:tdd-requirements {{要件名}} {{TASK-ID}}
```

完了したら step-c を実行する

## step-c: テストケース作成

以下の Task を実行する:

```
@Task tool (subagent_type: general-purpose, model: {{thinkTaskName}}) /tsumiki:tdd-testcases {{要件名}} {{TASK-ID}}
```

完了後:
- hilモード=true の場合: step-c1 を実行する
- hilモード=false の場合: step-d を実行する

## step-c1: ユーザー確認（hilモード時のみ）

作成されたテストケース一覧を以下の形式で表示する:

```
📋 作成されたテストケース (N個):

【正常系テストケース】
...

【異常系テストケース】
...

【境界値テストケース】
...

🔍 テストケースレビューポイント:
- 要件カバレッジ: N%
- エッジケースカバレッジ: N%
- エラーケースカバレッジ: N%

⏸️  このテストケースで実装を進めてよろしいですか?
```

AskUserQuestion ツールでユーザーの選択を取得する:
- **承認**: step-d を実行する
- **修正**: ユーザーの指示に基づいてテストケースを修正後、step-c1 に戻る
- **キャンセル**: 実装を中断し、現在の状態を保存して終了

## step-d: テスト実装 (tdd-red)

以下の Task を実行する:

```
@Task tool (subagent_type: general-purpose, model: {{tddTaskName}}) /tsumiki:tdd-red {{要件名}} {{TASK-ID}}
```

完了したら step-e を実行する

## step-e: 最小実装 (tdd-green)

以下の Task を実行する:

```
@Task tool (subagent_type: general-purpose, model: {{tddTaskName}}) /tsumiki:tdd-green {{要件名}} {{TASK-ID}}
```

完了したら step-f を実行する

## step-f: リファクタリング (tdd-refactor)

以下の Task を実行する:

```
@Task tool (subagent_type: general-purpose, model: {{tddTaskName}}) /tsumiki:tdd-refactor {{要件名}} {{TASK-ID}}
```

完了したら step-g を実行する

## step-g: 品質確認 (tdd-verify-complete)

以下の Task を実行する:

```
@Task tool (subagent_type: general-purpose, model: {{tddTaskName}}) /tsumiki:tdd-verify-complete {{要件名}} {{TASK-ID}}
```

判定結果に応じた処理:
- **テストケース不足**: 不足内容を明示した上で step-d（tdd-red）に戻り、テストケースを追加
- **実装不足（テストケースは十分）**: 失敗テストを明示した上で step-e（tdd-green）に戻り、実装を追加
- **スコープ外のみ失敗**: step-h へ進む + ユーザーに `/tsumiki:auto-debug` 推奨を通知
- **OK**: step-h へ進む

## step-h: タスク完了処理

- `docs/tasks/{要件名}/overview.md` の完了チェックボックスを更新する:
  - `[ ] **タスク完了**` → `[x] **タスク完了**`
- TaskUpdate でステータスを 'completed' に更新する
- 実装サマリーを以下の形式で表示する:

```
🎉 タスク {{TASK-ID}} が完了しました！

✅ タスクファイルのチェックボックスを更新しました
✅ Claude Codeタスク #{{claude_task_id}} を完了に設定しました

📊 実装サマリー:
- 実装タイプ: TDDプロセス (個別Task実行)
- 実行Taskステップ: N個 (全て成功)
- 品質確認の繰り返し: N回
- 作成ファイル: N個
- テストケース: N個 (全て成功)
- テストカバレッジ: N%
- 要件充足度: N%

📝 次の推奨タスク:
- {{次のタスクID}}: {{次のタスク名}}
```

- 依存関係が解消された次のタスクを TaskList で確認して提案する

# rules

MUST: 各フェーズは必ず個別 Task として実行すること
MUST: --hil 指定時は step-c 完了後に必ず step-c1 を実行し、ユーザーの承認を待つこと
MUST: --hil 指定時はユーザーが承認するまで step-d 以降を実行しないこと
MUST: step-g でテストケース不足と判定された場合、不足内容を明示して step-d に戻ること
MUST: step-g で実装不足と判定された場合、失敗テストを明示して step-e に戻ること
NEVER: 品質確認で問題が見つかった場合、警告なしで次に進まないこと
