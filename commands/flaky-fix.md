---
description: 不安定なテスト（flaky test）の原因を分析し、テストの安定化を試みます。auto-debugから委譲される他、ユーザが直接呼び出すことも可能です。
allowed-tools: Read, Glob, Grep, Task, Edit, Write
argument-hint: "[テストファイルパス]"
---
flaky testを安定化して。

# context

```
test_command: {{test_command}} (テスト実行コマンド。未指定の場合は npm test)
test_file: {{test_file}} (対象テストファイル)
error_output: {{error_output}} (失敗時のエラー出力)
max_retry: 2 (修正の最大リトライ回数)
stability_runs: 3 (安定性確認の実行回数)
```

# step

## step0: プロジェクトコンテキストの確認

以下のファイルが存在する場合は読み取り、テスト実行方法や開発ルールを把握する:
- `CLAUDE.md` — テスト実行方法、プロジェクト固有の指示
- `README.md` — テストフレームワーク、セットアップ手順
- `AGENTS.md` — エージェント向けの開発ルール

test_command が未指定の場合は、これらの情報から適切なテストコマンドを決定する。

## step1: flaky原因の分析

1. **テストファイルと関連コードの読み取り**
   - 対象テストファイルを Read tool で読み取り
   - テスト対象の実装ファイルを特定

2. **原因分析**（Task tool, subagent_type: Explore, thoroughness: **medium**）
   - 以下のflaky原因パターンに沿って分析:
     - **タイミング依存**: 非同期処理のawait不足、setTimeout依存、競合状態
     - **共有状態**: グローバル変数、DB状態、ファイルシステム状態のテスト間汚染
     - **外部サービス依存**: API呼び出し、ネットワーク通信、外部DB
     - **ランダム性**: Math.random, Date.now, UUID生成等の非決定的処理
     - **順序依存**: テスト実行順序に依存する暗黙の前提
     - **リソース制限**: メモリ不足、ファイルディスクリプタ枯渇、ポート競合
   - 最も可能性の高い原因を特定し、修正方針を決定

## step2: テストコードの修正

原因に応じた修正を実施（general-purpose subagent）:

1. **タイミング依存の場合**
   - 不足しているawaitの追加
   - setTimeout → 適切なイベント待機に変更
   - waitFor / waitForExpect パターンの導入
   - テスト用のタイムアウト値を十分に確保

2. **共有状態の場合**
   - beforeEach/afterEachでの状態初期化・クリーンアップ追加
   - テスト専用のデータ生成（ユニークなID/名前）
   - テスト間の依存関係の排除

3. **外部サービス依存の場合**
   - テスト用モック/スタブの導入
   - MSW (Mock Service Worker) 等のHTTPモックの設定
   - テスト用のインメモリDB切り替え

4. **ランダム性の場合**
   - Math.random → seed付き乱数生成に変更
   - Date.now → jest.useFakeTimers() / vi.useFakeTimers()
   - テスト用の固定値モック

5. **順序依存の場合**
   - 各テストの独立性を確保
   - 暗黙の前提条件を明示的なsetupに変換

6. **リソース制限の場合**
   - afterEachでのリソース解放追加
   - 接続プールの適切な管理

## step3: 安定性確認

1. **修正後のテストを複数回実行**
   ```bash
   # stability_runs 回連続実行
   {{test_command}} -- {{test_file}}
   {{test_command}} -- {{test_file}}
   {{test_command}} -- {{test_file}}
   ```

2. **結果判定**
   - **全回成功**: 安定化成功。step4へ
   - **1回でも失敗**:
     - retry_count < max_retry → 別のアプローチで step1 に戻る
     - retry_count >= max_retry → 安定化不能としてレポート

## step4: 結果レポート

```markdown
# flaky-fix 結果レポート

## 結果: [安定化成功 / 安定化失敗]

## 対象テスト
- ファイル: {{test_file}}

## flaky原因
- 原因分類: [タイミング依存 / 共有状態 / 外部依存 / ランダム性 / 順序依存 / リソース制限]
- 詳細: [具体的な原因]

## 修正内容
（修正した場合のみ）
- 修正ファイル: [ファイルパス]
- 修正内容: [具体的な変更内容]
- 安定性確認: X回連続成功

## 未解決
（安定化できなかった場合のみ）
- 試行した修正: [各試行の内容]
- 推奨対応: [手動での安定化が必要な理由と方針]
```

# rule

NEVER: テストの削除やスキップによる「安定化」
NEVER: テストの期待値を緩くする（assertionの弱化）
MUST: テストの意図（何を検証するか）を変えない
MUST: 安定性確認は最低3回連続成功
MUST: 修正はテストコード側を優先（実装コードの変更は最小限）
