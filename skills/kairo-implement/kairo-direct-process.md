直接作業プロセスを実行します。direct-setup → direct-verify の順に各フェーズを個別Taskで実行します。

# context

tddTaskName={{tddTaskName}}
要件名={{requirement_name}}
TASK-ID={{task_id}}
claude_task_id={{claude_task_id}}

# step

- context の内容を確認する
- step-a を実行する

## step-a: 準備作業の実行 (direct-setup)

以下の Task を実行する:

```
@Task tool (subagent_type: general-purpose, model: {{tddTaskName}}) /tsumiki:direct-setup {{要件名}} {{TASK-ID}}
```

完了したら step-b を実行する

## step-b: 作業結果の確認 (direct-verify)

以下の Task を実行する:

```
@Task tool (subagent_type: general-purpose, model: {{tddTaskName}}) /tsumiki:direct-verify {{要件名}} {{TASK-ID}}
```

完了したら step-c を実行する

## step-c: タスク完了処理

- `docs/tasks/{要件名}/overview.md` の完了チェックボックスを更新する:
  - `[ ] **タスク完了**` → `[x] **タスク完了**`
- TaskUpdate でステータスを 'completed' に更新する
- 実装サマリーを以下の形式で表示する:

```
🎉 タスク {{TASK-ID}} が完了しました！

✅ タスクファイルのチェックボックスを更新しました
✅ Claude Codeタスク #{{claude_task_id}} を完了に設定しました

📊 実装サマリー:
- 実装タイプ: 直接作業プロセス (個別Task実行)
- 実行Taskステップ: 2個 (全て成功)
- 作成ファイル: N個
- 設定更新: N個
- 環境確認: 正常

📝 次の推奨タスク:
- {{次のタスクID}}: {{次のタスク名}}
```

- 依存関係が解消された次のタスクを TaskList で確認して提案する

# rules

MUST: 各フェーズは必ず個別 Task として実行すること
MUST: step-b で検証エラーが発生した場合、詳細をユーザーに報告して対応を確認すること
NEVER: 作業確認が完了しないまま完了処理を実行しないこと
