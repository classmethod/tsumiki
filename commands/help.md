---
description: tsumikiの利用可能なコマンド一覧表示、個別コマンドの詳細ヘルプ、困りごとからの最適コマンド検索を行います。
allowed-tools: Read, Glob, Grep
argument-hint: "[コマンド名 or 困りごとテキスト（省略可）]"
---
tsumikiのヘルプを表示して。

# context

```
args: {{args}} (引数。空=一覧表示、コマンド名=詳細、それ以外=困りごと検索)
```

# step

## step1: モード判定

引数の内容に基づいて実行モードを判定する:

1. **引数なし** → **Mode A: カテゴリ別一覧表示**（step2へ）
2. **引数が以下のコマンド名に一致** → **Mode B: コマンド詳細表示**（step3へ）
   - 一致判定対象のコマンド名リスト:
     - kairo-requirements, kairo-design, kairo-tasks, kairo-loop, kairo-implement
     - tdd-requirements, tdd-testcases, tdd-red, tdd-green, tdd-refactor, tdd-verify-complete
     - auto-debug, build-fix, flaky-fix, env-fix, timeout-fix
     - init-tech-stack, direct-setup, direct-verify
     - orchestrate, help
     - rev-requirements, rev-design, rev-specs, rev-tasks
     - dcs:bug-analysis, dcs:edgecase-analysis, dcs:feature-rubber-duck, dcs:impact-analysis, dcs:incremental-dev, dcs:performance-analysis, dcs:sequence-diagram-analysis, dcs:state-transition-analysis, dcs:test-performance-analysis
   - `/tsumiki:` プレフィックス付き（例: `/tsumiki:auto-debug`）や `/` プレフィックス付き（例: `/auto-debug`）でも一致とみなす
3. **上記に一致しない** → **Mode C: 困りごと検索**（step4へ）

## step2: Mode A — カテゴリ別一覧表示

以下の内容をそのまま表示する:

```
# tsumiki コマンド一覧

## Kairo開発（要件定義〜実装の一気通貫開発）

| コマンド | 説明 |
|---------|------|
| /tsumiki:kairo-requirements | 要件の概要からEARS記法を使用した詳細な要件定義書を作成 |
| /tsumiki:kairo-design | 承認された要件定義書に基づいて技術設計文書を生成 |
| /tsumiki:kairo-tasks | 設計文書に基づいて実装タスクを1日単位で分割・フェーズ管理 |
| /tsumiki:kairo-loop | 指定したTASK範囲のkairo実装を開始から終了まで順番に自動実行 |
| /tsumiki:kairo-implement | 分割されたタスクを順番に、またはユーザが指定したタスクをTDDで実装 |

## TDD開発（テスト駆動開発の各フェーズ）

| コマンド | 説明 |
|---------|------|
| /tsumiki:tdd-requirements | TDD開発の要件整理。機能要件を明確化 |
| /tsumiki:tdd-testcases | 要件に基づいた包括的なテストケースの洗い出し |
| /tsumiki:tdd-red | Redフェーズ: 失敗するテストケースを作成 |
| /tsumiki:tdd-green | Greenフェーズ: テストを通す実装を行う |
| /tsumiki:tdd-refactor | Refactorフェーズ: コード品質の改善 |
| /tsumiki:tdd-verify-complete | すべてのテストケースの実装完了を検証 |

## デバッグ・修正

| コマンド | 説明 |
|---------|------|
| /tsumiki:auto-debug | テストエラーの自動デバッグ。全テスト確認→原因調査→修正まで一括実行 |
| /tsumiki:build-fix | ビルドエラー（コンパイル・型・依存パッケージ）を自動分析・修正 |
| /tsumiki:flaky-fix | 不安定なテスト（flaky test）の原因分析と安定化 |
| /tsumiki:env-fix | 環境依存問題（パッケージ不足・環境変数・設定不備）を自動修正 |
| /tsumiki:timeout-fix | テスト実行のタイムアウト問題を分析し高速化または分離 |

## セットアップ

| コマンド | 説明 |
|---------|------|
| /tsumiki:init-tech-stack | プロジェクト初期設定として技術スタックを選定 |
| /tsumiki:direct-setup | DIRECTタスクの設定作業（環境構築・設定ファイル・依存関係） |
| /tsumiki:direct-verify | DIRECTタスクの動作確認とテスト |

## リバースエンジニアリング（既存コードからドキュメント逆生成）

| コマンド | 説明 |
|---------|------|
| /tsumiki:rev-tasks | 既存コードベースを分析しタスク一覧として整理 |
| /tsumiki:rev-design | 既存コードベースから技術設計文書を逆生成 |
| /tsumiki:rev-specs | 既存コードベースからテストケースと仕様書を逆生成 |
| /tsumiki:rev-requirements | 既存コードベースから要件定義書を逆生成 |

## DCS分析（Deep Code Survey）

| コマンド | 説明 |
|---------|------|
| /tsumiki:dcs:bug-analysis | バグの原因を特定するための詳細分析を実施 |
| /tsumiki:dcs:edgecase-analysis | エッジケース・エラー状態を包括的に分析し洗い出す |
| /tsumiki:dcs:feature-rubber-duck | アイデアを整理して実現可能なPRDを作成 |
| /tsumiki:dcs:impact-analysis | 変更対象の影響範囲分析を実施 |
| /tsumiki:dcs:incremental-dev | 増分開発の計画を立案 |
| /tsumiki:dcs:performance-analysis | 性能問題の原因を調査 |
| /tsumiki:dcs:sequence-diagram-analysis | 機能のシーケンス図をmermaid形式で作成 |
| /tsumiki:dcs:state-transition-analysis | データの状態遷移フローを包括的に分析 |
| /tsumiki:dcs:test-performance-analysis | テスト実行速度を分析しリファクタリング提案を行う |

## その他

| コマンド | 説明 |
|---------|------|
| /tsumiki:orchestrate | 複雑な依頼を自動分析しエージェントチームで実行・検証・再試行 |

---

**使い方:**
- `/tsumiki:help <コマンド名>` — コマンドの詳細ヘルプを表示（例: `/tsumiki:help auto-debug`）
- `/tsumiki:help <困りごと>` — 困りごとに対応するコマンドを検索（例: `/tsumiki:help テストが失敗する`）
```

表示したら終了。

## step3: Mode B — コマンド詳細表示

1. **コマンドファイルの読み取り**
   - `commands/{{コマンド名}}.md` を Read tool で読み取る

2. **以下の情報を抽出して表示**

```
# /tsumiki:{{コマンド名}}

## 概要
{{frontmatter の description}}

## 使い方
/tsumiki:{{コマンド名}} {{frontmatter の argument-hint}}

## 処理ステップ
（コマンドファイル内の `## step` セクションを要約。各ステップのタイトルと1行説明を箇条書き）

## 注意事項
（コマンドファイル内の `# rule` セクションの NEVER / MUST ルールを箇条書き）
```

3. 表示したら終了。

## step4: Mode C — 困りごと検索

### step4-1: 定型マッピングによる検索

入力テキストに以下のキーワードが含まれるかチェックする。**複数一致する場合はすべて表示**する:

| キーワード | 推奨コマンド | 説明 |
|-----------|-------------|------|
| テスト失敗, テストエラー, デバッグ, テストが落ちる, テスト修正 | /tsumiki:auto-debug | テストエラーの自動デバッグ |
| ビルドエラー, コンパイルエラー, 型エラー, ビルドが通らない, TypeScriptエラー | /tsumiki:build-fix | ビルドエラーの自動修正 |
| テスト不安定, flaky, たまに落ちる, ランダムに失敗, 不安定なテスト | /tsumiki:flaky-fix | flakyテストの安定化 |
| タイムアウト, テストが遅い, 時間がかかる, timeout | /tsumiki:timeout-fix | タイムアウト問題の改善・テスト分離 |
| 環境エラー, パッケージ不足, 環境変数, npm ci, モジュール不足, Cannot find module | /tsumiki:env-fix | 環境依存問題の自動修正 |
| TDD, テスト駆動, テストから書きたい, テストファースト | /tsumiki:tdd-requirements | TDD開発の要件整理から開始 |
| 要件定義, 要件整理, 仕様を決めたい | /tsumiki:kairo-requirements | EARS記法による要件定義書作成 |
| 設計, アーキテクチャ, 技術設計 | /tsumiki:kairo-design | 技術設計文書の生成 |
| タスク分割, 実装計画, スケジュール | /tsumiki:kairo-tasks | タスクの分割とフェーズ管理 |
| 実装したい, コードを書きたい, 機能追加, 一気通貫 | /tsumiki:kairo-loop | TASK範囲のkairo実装を自動実行 |
| タスク実装, TDD実装, kairo実装, タスクを実装したい | /tsumiki:kairo-implement | 分割されたタスクをTDDで順番に実装 |
| 技術スタック, プロジェクト初期設定, 初期化 | /tsumiki:init-tech-stack | 技術スタックの選定 |
| 複雑なタスク, 自動化, 一括実行, 複数ステップ | /tsumiki:orchestrate | エージェントチームによる自動実行 |
| 設定作業, 環境構築, セットアップ | /tsumiki:direct-setup | DIRECT設定作業の実行 |
| 動作確認, 設定検証 | /tsumiki:direct-verify | DIRECTタスクの動作確認 |
| リバースエンジニアリング, 既存コード分析, ドキュメント逆生成, タスク抽出 | /tsumiki:rev-tasks | 既存コードからタスク一覧を整理 |
| 既存コード設計, 設計書逆生成, アーキテクチャ抽出 | /tsumiki:rev-design | 既存コードから技術設計文書を逆生成 |
| 仕様逆生成, テストケース抽出, 仕様書生成 | /tsumiki:rev-specs | 既存コードからテストケース・仕様書を逆生成 |
| 要件逆生成, 要件抽出, EARS逆生成 | /tsumiki:rev-requirements | 既存コードから要件定義書を逆生成 |
| バグ分析, バグ調査, 原因特定 | /tsumiki:dcs:bug-analysis | バグの原因を詳細分析 |
| エッジケース, 異常系, エラー状態, 境界値 | /tsumiki:dcs:edgecase-analysis | エッジケース・エラー状態の包括分析 |
| 仕様の壁打ち, アイデア整理, 要件を相談, PRD作成 | /tsumiki:dcs:feature-rubber-duck | アイデアを整理してPRDを作成 |
| 影響範囲, 影響分析, 変更影響, リスク評価 | /tsumiki:dcs:impact-analysis | 変更対象の影響範囲分析 |
| 増分開発, 段階的実装, インクリメンタル | /tsumiki:dcs:incremental-dev | 増分開発の計画立案 |
| 性能問題, パフォーマンス, レスポンス遅い, 速度改善 | /tsumiki:dcs:performance-analysis | 性能問題の原因調査 |
| シーケンス図, 処理フロー, mermaid, フロー図 | /tsumiki:dcs:sequence-diagram-analysis | シーケンス図をmermaid形式で作成 |
| 状態遷移, ステート, ステータス管理, ライフサイクル | /tsumiki:dcs:state-transition-analysis | データの状態遷移フロー分析 |
| テスト速度分析, テスト遅い原因, テスト計測 | /tsumiki:dcs:test-performance-analysis | テスト実行速度の分析とリファクタリング提案 |

### step4-2: 結果の表示

**一致あり の場合:**

```
# 「{{入力テキスト}}」に対応するコマンド

{{一致したコマンドごとに:}}
## /tsumiki:{{コマンド名}}
{{説明}}

---
`/tsumiki:help {{コマンド名}}` で詳細を確認できます。
```

**一致なし の場合（AI推論フォールバック）:**

全対象コマンドの description を参照し、入力テキストの困りごとに最も適したコマンドを推論する:

1. 全対象コマンド（33件）の description とステップ概要を把握
2. 入力テキストの意図を分析
3. 関連度の高いコマンドを最大3件まで推薦
4. 「該当するコマンドが見つかりませんでした」の場合もありうる

```
# 「{{入力テキスト}}」に関連するコマンド（AI推論）

{{推薦コマンドごとに:}}
## /tsumiki:{{コマンド名}}
{{description}}
推薦理由: {{なぜこのコマンドが関連するか}}

---
`/tsumiki:help {{コマンド名}}` で詳細を確認できます。
```

# rule

NEVER: コマンドの description を改変して表示する
MUST: Mode B でコマンドファイルを読み取る際は Read tool を使用する
MUST: Mode C の定型マッピングで一致がない場合のみ AI推論を使用する
MUST: AI推論の結果には「AI推論」であることを明示する
