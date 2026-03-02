---
description: ビルドエラー（コンパイルエラー、型エラー、依存パッケージ未解決）を自動的に分析・修正します。auto-debugから委譲される他、ユーザが直接呼び出すことも可能です。
allowed-tools: Read, Glob, Grep, Task, Edit, Write
argument-hint: "[エラー内容（省略可）]"
---
ビルドエラーを解消して。

# context

```
test_command: {{test_command}} (テスト実行コマンド。未指定の場合は npm test)
error_output: {{error_output}} (ビルドエラーの出力内容)
max_retry: 3 (最大リトライ回数)
retry_count: 0 (現在のリトライ回数)
```

# step

## step0: プロジェクトコンテキストの確認

以下のファイルが存在する場合は読み取り、テスト実行方法や開発ルールを把握する:
- `CLAUDE.md` — テスト実行方法、プロジェクト固有の指示
- `README.md` — セットアップ手順、ビルド方法
- `AGENTS.md` — エージェント向けの開発ルール

test_command が未指定の場合は、これらの情報から適切なテストコマンドを決定する。

## step1: ビルドエラーの分析

1. **エラー出力の取得**
   - error_output が提供されている場合はそれを使用
   - 提供されていない場合は以下を実行:
     ```bash
     {{test_command}} 2>&1
     ```

2. **エラー種別の特定**
   - Task tool (subagent_type: Explore, thoroughness: **medium**) を使用
   - 以下のエラー分類に従って分析:
     - **構文エラー**: SyntaxError, Unexpected token 等
     - **型エラー**: TS2xxx系エラー, TypeError at compile time 等
     - **依存パッケージ未解決**: Cannot find module, Module not found, Cannot resolve 等
     - **設定ファイル不備**: 設定ファイルの構文エラー, 未定義のプロパティ参照 等
   - エラー箇所（ファイル名、行番号）を特定
   - 修正方針を決定

## step2: 自動修正の試行

エラー種別に応じた修正を実施:

1. **依存パッケージ未解決の場合**
   - `package.json` / `requirements.txt` 等を確認
   - 不足パッケージを特定
   ```bash
   npm install {{missing_package}}
   ```
   - または `npm ci`（lockfileとの不整合の場合）

2. **import文エラーの場合**
   - 正しいモジュールパスを探索（Explore quick）
   - import文を修正（Edit tool）

3. **型エラーの場合**
   - 型定義ファイルの不足: `npm install -D @types/{{package}}`
   - 型注釈の誤り: コード修正（Edit tool）
   - tsconfig.json の設定不備: 設定修正

4. **構文エラーの場合**
   - エラー箇所のコードを読み取り（Read tool）
   - 構文エラーを修正（Edit tool）

5. **設定ファイル不備の場合**
   - 設定ファイルの構文チェック
   - 不足プロパティの追加、誤記の修正

## step3: ビルド再実行による確認

1. **テスト（ビルド）を再実行**
   ```bash
   {{test_command}} 2>&1
   ```

2. **結果判定**
   - **ビルド成功（テスト実行段階まで到達）**: 修正完了。修正内容を報告して終了
   - **別のビルドエラーが発生**: retry_count < max_retry なら step1 に戻る
   - **同じビルドエラーが継続**: retry_count < max_retry なら別のアプローチで step2 を再試行
   - **retry_count >= max_retry**: 修正不能としてレポートを出力して終了

## step4: 結果レポート

```markdown
# build-fix 結果レポート

## 結果: [成功 / 部分成功 / 失敗]

## 修正内容
（修正した場合のみ）
- エラー種別: [構文エラー / 型エラー / 依存パッケージ / 設定不備]
- 修正ファイル: [ファイルパス]
- 修正内容: [具体的な変更内容]
- リトライ回数: X/3

## 未解決のエラー
（修正できなかった場合のみ）
- エラー内容: [エラーメッセージ]
- 試行した修正: [各試行の内容]
- 推奨対応: [手動での修正が必要な理由と方針]
```

# rule

NEVER: ソースコードのロジック変更（ビルドを通すための最小限の修正のみ）
NEVER: テストコードの削除やスキップ
MUST: 修正はビルドエラーの解消に直接関係するもののみ
MUST: 依存パッケージの追加時はバージョンを明示
MUST: 各リトライで前回と異なるアプローチを試みる
