---
description: テスト実行に必要な環境依存問題（パッケージ不足、環境変数未設定、設定ファイル不備、外部サービス未起動）を自動的に分析・修正します。auto-debugから委譲される他、ユーザが直接呼び出すことも可能です。
allowed-tools: Read, Glob, Grep, Task, Edit, Write
argument-hint: "[テストファイルパス（省略可）]"
---
環境依存問題を解消して。

# context

```
test_command: {{test_command}} (テスト実行コマンド。未指定の場合は npm test)
test_file: {{test_file}} (対象テストファイル。未指定の場合は全テスト)
error_output: {{error_output}} (エラー出力内容)
error_classification: {{error_classification}} (エラー分類。⚙️設定・環境問題 / 📦依存関係問題)
max_retry: 2 (最大リトライ回数)
```

# step

## step0: プロジェクトコンテキストの確認

以下のファイルが存在する場合は読み取り、テスト実行方法や環境要件を把握する:
- `CLAUDE.md` — テスト実行方法、環境設定の指示
- `README.md` — セットアップ手順、必要な環境変数、外部サービス要件
- `AGENTS.md` — エージェント向けの開発ルール、環境関連の注意事項

test_command が未指定の場合は、これらの情報から適切なテストコマンドを決定する。

## step1: 環境問題の分析

1. **エラー出力の確認**
   - error_output が提供されている場合はそれを分析
   - 提供されていない場合はテストを実行してエラーを取得

2. **原因分析**（Task tool, subagent_type: Explore, thoroughness: **medium**）
   - 以下の環境問題パターンに沿って分析:
     - **依存パッケージ不足/不整合**: package.json と node_modules の不一致、lockfile の不整合
     - **環境変数未設定**: 必要な環境変数が未定義、.env ファイルの不備
     - **設定ファイル不備**: 設定ファイルの不足、パス設定の誤り
     - **外部サービス未起動**: DB、Redis、メッセージキュー等の未起動
     - **Node.js/ランタイムバージョン不整合**: .nvmrc / .node-version との不一致
   - 修正可能な問題と手動対応が必要な問題を分類

## step2: 自動修正の試行

問題種別に応じた修正を実施:

1. **依存パッケージ不足/不整合の場合**
   ```bash
   # lockfileとの同期
   npm ci
   ```
   - `npm ci` が失敗した場合:
   ```bash
   rm -rf node_modules && npm install
   ```
   - Python の場合:
   ```bash
   pip install -r requirements.txt
   ```

2. **環境変数未設定の場合**
   - `.env.example` / `.env.sample` / `.env.template` が存在するか確認
   - 存在する場合: `.env.test` または `.env` にコピー
   - 存在しない場合: エラーメッセージから必要な環境変数を特定し、テスト用デフォルト値で `.env.test` を生成
   - 注意: 機密情報（APIキー等）はプレースホルダで記載し、レポートで手動設定を推奨

3. **設定ファイル不備の場合**
   - テンプレートや既存設定からの生成
   - パス設定の修正（相対パス/絶対パスの変換）
   - 不足プロパティの追加

4. **外部サービス未起動の場合**
   - `docker-compose.yml` / `compose.yml` が存在するか確認
   - 存在する場合:
   ```bash
   docker compose up -d
   ```
   - 存在しない場合: 手動起動が必要としてレポート

5. **ランタイムバージョン不整合の場合**
   - `.nvmrc` / `.node-version` の内容を報告
   - 自動修正は行わず、レポートで推奨バージョンを記載

## step3: テスト再実行による確認

1. **テストを再実行**
   ```bash
   {{test_command}} 2>&1
   ```
   - test_file が指定されている場合:
   ```bash
   {{test_command}} -- {{test_file}} 2>&1
   ```

2. **結果判定**
   - **成功**: 修正完了。step4へ
   - **同じ環境エラーが継続**: retry_count < max_retry → 別のアプローチで step2 を再試行
   - **別の問題が発生**: 環境問題が解消されたか確認し、新たな問題は報告
   - **retry_count >= max_retry**: 修正不能としてレポート

## step4: 結果レポート

```markdown
# env-fix 結果レポート

## 結果: [成功 / 部分成功 / 失敗]

## 検出された問題
- 問題種別: [依存パッケージ / 環境変数 / 設定ファイル / 外部サービス / ランタイムバージョン]
- 詳細: [具体的な問題内容]

## 自動修正内容
（修正した場合のみ）
- 実行したコマンド: [コマンド一覧]
- 修正したファイル: [ファイル一覧]
- リトライ回数: X/2

## 手動対応が必要な項目
（自動修正できなかった場合のみ）
- 問題: [問題内容]
- 推奨対応: [具体的な手順]
```

# rule

NEVER: 機密情報（APIキー、パスワード等）をハードコードする
NEVER: 本番環境の設定を変更する
NEVER: グローバルなパッケージインストール（npm install -g）
MUST: 環境変数の値にプレースホルダが含まれる場合はレポートで明記
MUST: docker compose 実行前にDockerが起動しているか確認
MUST: パッケージインストール後はlockfileの変更をレポート
