# Tsumiki - AI駆動開発支援フレームワーク

TsumikiはAI駆動開発のためのフレームワークです。要件定義から実装まで、AIを活用した効率的な開発プロセスを提供します。

基本的にClaude Codeをサポートしますが、それ以外のツールでも使用できます。[Claude Code以外のツールでtsumikiを使用する](#claude-code以外のツールでtsumikiを使用する) を参照してください。

## インストール

Tsumikiを使用するには、次のClaude Code Pluginコマンドでインストールしてください：

```bash
/plugin marketplace add https://github.com/classmethod/tsumiki.git
/plugin install tsumiki@tsumiki
```

このコマンドを実行すると、TsumikiのClaude Codeスラッシュコマンドとエージェントが自動的にインストールされます。

**注意**: コマンドは `/tsumiki:` プレフィックス付きで実行します（例：`/tsumiki:dev-plan`）。

### レガシープラグイン（オプトイン）

`Kairo` / `TDD` / `DIRECT` の従来コマンドは、オプトインのレガシープラグイン `tsumiki-legacy` として分離されています。これらを利用する場合は、追加で次のコマンドを実行してください：

```bash
/plugin install tsumiki-legacy@tsumiki
```

**注意**: レガシーコマンドは `/tsumiki-legacy:` プレフィックス付きで実行します（例：`/tsumiki-legacy:kairo-requirements`）。

## 概要

Tsumikiは以下のカテゴリで構成されています：

| カテゴリ | 説明 |
|---------|------|
| **Dev Skills** | コンテキスト分析・計画・実装・検証・デバッグの統合ワークフロー |
| **DCS** | コードベースの分析・調査・ドキュメント生成 |
| **ユーティリティ** | デバッグ支援・小規模修正・オーケストレーション等 |
| **リバースエンジニアリング** | 既存コードからドキュメントを逆生成 |
| **Kairo**（Legacy） | 要件定義から実装までの包括的な開発フロー（`tsumiki-legacy` プラグイン） |
| **TDD**（Legacy） | テスト駆動開発の個別実行（`tsumiki-legacy` プラグイン） |
| **DIRECT**（Legacy） | 設定作業の実行・検証（`tsumiki-legacy` プラグイン） |

## 利用可能なコマンド

### Dev Skills（統合開発ワークフロー）

Dev Skillsは、プロジェクト分析から実装・検証・Webテストまでをカバーする統合的な開発スキル群です。

| スキル | 説明 |
|-------|------|
| `dev-init` | 新規プロジェクトの技術スタック選定・初期化 |
| `dev-context` | 既存プロジェクトのコンテキスト自動分析 |
| `dev-navigate` | やりたいことから最適なスキルをナビゲーション |
| `dev-plan` | 要件をタスク分解して実装計画を作成 |
| `dev-impl` | テストファースト実装（通常/クイックモード） |
| `dev-run` | タスク範囲の自動連続実装 |
| `dev-verify` | Plan単位のテスト・ビルド・Lint一括検証 |
| `dev-debug` | エラーカテゴリ別の診断・修正 |
| `dev-screen-spec` | ソースコードから画面仕様を自動生成・更新 |
| `dev-webtest-plan` | Playwright用Webテスト計画の生成 |
| `dev-webtest` | Playwrightによる画面テスト実行 |

詳細は [DEV_README.md](./DEV_README.md) を参照してください。

### DCSコマンド（分析・調査）

DCSはコードベースの分析・調査を支援するコマンドスイートです。

| コマンド | 説明 |
|---------|------|
| `dcs:feature-rubber-duck` | アイデア整理とPRD作成 |
| `dcs:sequence-diagram-analysis` | シーケンス図作成 |
| `dcs:state-transition-analysis` | 状態遷移分析 |
| `dcs:impact-analysis` | 影響範囲分析 |
| `dcs:incremental-dev` | 増分開発計画 |
| `dcs:bug-analysis` | バグ原因分析 |
| `dcs:performance-analysis` | 性能問題調査 |
| `dcs:code-question` | ソースコードに関する質問回答 |
| `dcs:edgecase-analysis` | エッジケース・異常系分析 |

詳細は [DCS_README.md](./DCS_README.md) を参照してください。

### ユーティリティコマンド

| コマンド | 説明 |
|---------|------|
| `help` | コマンド一覧・詳細ヘルプ・困りごと検索 |
| `orchestrate` | 複雑な依頼を自動分析しエージェントチームで実行 |
| `refine-plan` | 既存コード・ドキュメントへの小規模修正計画 |
| `refine-execute` | refine-planで作成した計画の実行 |
| `auto-debug` | テストエラーの自動デバッグ |
| `build-fix` | ビルドエラーの自動修正 |
| `env-fix` | 環境依存問題の自動修正 |
| `flaky-fix` | 不安定テストの安定化 |
| `timeout-fix` | タイムアウト問題の解決 |

### リバースエンジニアリングコマンド

| コマンド | 説明 |
|---------|------|
| `rev-tasks` | 既存コードからタスク構造を分析 |
| `rev-design` | 既存コードから設計文書を逆生成 |
| `rev-specs` | 既存コードからテスト仕様書を逆生成 |
| `rev-requirements` | 既存コードから要件定義書を逆生成 |

### レガシーコマンド（`tsumiki-legacy` プラグイン）

以下は従来の `Kairo` / `TDD` / `DIRECT` コマンドです。オプトインの `tsumiki-legacy` プラグイン（[インストール方法](#レガシープラグインオプトイン)）に含まれ、`/tsumiki-legacy:` プレフィックスで実行します。

#### Kairoコマンド（包括的開発フロー）

| コマンド | 説明 |
|---------|------|
| `init-tech-stack` | 技術スタックの特定 |
| `kairo-requirements` | 要件定義（EARS記法） |
| `kairo-design` | 設計文書生成 |
| `kairo-tasks` | タスク分割 |
| `kairo-implement` | 実装実行（Skills版・TDD/DIRECTを内部で使用） |
| `kairo-loop` | タスク範囲指定の自動連続実装（compact対応） |

#### TDDコマンド（個別実行）

| コマンド | 説明 |
|---------|------|
| `tdd-requirements` | TDD要件定義 |
| `tdd-testcases` | テストケース作成 |
| `tdd-red` | テスト実装（Red） |
| `tdd-green` | 最小実装（Green） |
| `tdd-refactor` | リファクタリング |
| `tdd-verify-complete` | TDD完了確認 |

#### DIRECTコマンド

| コマンド | 説明 |
|---------|------|
| `direct-setup` | DIRECTタスクの設定作業を実行 |
| `direct-verify` | DIRECTタスクの設定作業を検証 |

> **補足**: `kairo-implement` は Skills として提供され、上記コマンド群とともにすべて `tsumiki-legacy` プラグインに含まれます。

## クイックスタート

**注意**: Claude Code Pluginでインストールした場合、基本コマンドは `tsumiki:`、レガシーコマンドは `tsumiki-legacy:` プレフィックスを付けてください。

### Kairoによる包括的な開発フロー（Legacy）

`tsumiki-legacy` プラグインが必要です。

```bash
# 1. 技術スタック初期化
/tsumiki-legacy:init-tech-stack

# 2. 要件定義
/tsumiki-legacy:kairo-requirements

# 3. 設計
/tsumiki-legacy:kairo-design

# 4. タスク分割
/tsumiki-legacy:kairo-tasks

# 5. 実装（自動連続実装）
/tsumiki-legacy:kairo-loop
```

### Dev Skillsによる開発フロー

```bash
# 1. プロジェクトコンテキスト生成
/tsumiki:dev-context

# 2. 実装計画作成
/tsumiki:dev-plan auth "ユーザー認証機能を実装"

# 3. 自動連続実装
/tsumiki:dev-run auth 001 005

# 4. 検証
/tsumiki:dev-verify auth
```

### 個別TDDプロセス（Legacy）

`tsumiki-legacy` プラグインが必要です。

```bash
/tsumiki-legacy:tdd-requirements
/tsumiki-legacy:tdd-testcases
/tsumiki-legacy:tdd-red
/tsumiki-legacy:tdd-green
/tsumiki-legacy:tdd-refactor
/tsumiki-legacy:tdd-verify-complete
```

### リバースエンジニアリング

```bash
# 1. 既存コードからタスク構造を分析
/tsumiki:rev-tasks

# 2. 設計文書の逆生成（タスク分析後推奨）
/tsumiki:rev-design

# 3. テスト仕様書の逆生成（設計文書後推奨）
/tsumiki:rev-specs

# 4. 要件定義書の逆生成（全分析完了後推奨）
/tsumiki:rev-requirements
```

## Claude Code以外のツールでtsumikiを使用する

[rulesync](https://github.com/dyoshikawa/rulesync)を組み合わせて使用することで、Claude Code以外のツールでもtsumikiのコマンドを使用できます。

プロジェクトルートで以下のコマンドを実行します。

```
npx -y rulesync init
npx -y rulesync config --init
npx -y rulesync import \
  --targets claudecode \
  --features commands,subagents

# Gemini CLIのカスタムスラッシュコマンドを出力する場合は以下のようになります。
# （`--targets` には `claudecode`, `geminicli`, `roo` の指定が可能です）
npx -y rulesync generate \
  --targets geminicli \
  --features commands

# カスタムスラッシュコマンドの仕様が存在しない（または仕様的な制限のある）AIコーディングツールでも、 `--experimental-simulate-commands` フラグによりいくつかのツールではコマンドファイルを出力できます。
# Cursorのカスタムスラッシュコマンドを出力する場合は以下のようになります。
# （`--targets` には `cursor`, `copilot`, `codexcli` の指定が可能です）
npx -y rulesync generate \
  --targets cursor \
  --features commands
  --experimental-simulate-commands
```

詳しくは[rulesync](https://github.com/dyoshikawa/rulesync)のREADMEを参照してください。

## 詳細ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [MANUAL.md](./MANUAL.md) | Kairo・TDD・ユーティリティコマンドの詳細マニュアル |
| [DEV_README.md](./DEV_README.md) | Dev Skillsの詳細マニュアル |
| [DCS_README.md](./DCS_README.md) | DCSコマンドの詳細マニュアル |
