---
description: 指定したTASK範囲のkairo実装を開始から終了まで順番に自動実行し、品質確認・戻り処理・デバッグを含むループ処理を行います。
allowed-tools: Read, Glob, Grep, Task, Write, Edit, TodoWrite, AskUserQuestion, TaskList, TaskGet, TaskUpdate
argument-hint: "[要件名] [開始TASK-ID (TASK-00001)] [終了TASK-ID (TASK-00002)] "
---

- $1 がない場合、「引数に要件名・開始TASK-ID・終了TASK-IDを指定してください（例: /kairo-loop ユーザー認証システム TASK-00001 TASK-00005）」と言って終了する
- $2 がない場合、「引数に開始TASK-IDを指定してください（例: TASK-00001）」と言って終了する
- $3 がない場合、「引数に終了TASK-IDを指定してください（例: TASK-00005）」と言って終了する

$0 の $1 から順番に実行してください。 $2 まで完了したら一旦終了して。
以下の作業を実施してください
- /tsumiki:kairo-implement を理解して、skillの内容に正確に従ってください
- 実施する内容を全てtodoに詳細に記録してください。
- 品質確認の段階で戻る処理をするときは以下の手順を組み込んでください
  - 品質の確認処理
  - 戻り先決定ルールを品質確認後の戻る処理内に含めてください
  - 戻り先からのステップをそれぞれtodoに追加(例:step-e追加の場合は、step-e,step-f,step-g,品質確認を追加する)
  - 追加したtodoの依存関係を設定
  - 戻り先として追加したtaskに遷移する
- 最後のチェックボックスを入れる作業も含めて忘れずにtodoに追加してください
- todoには必ず依存関係を設定してください
- todoに記録が終わったら順番に実施してください
- 全ての TASK の完了が終わったら `/tsumiki:auto-debug` を実行する
