---
description: Kairo開発のコンテキスト情報を収集してノートにまとめます。技術スタック、追加ルール、関連ファイルの情報を整理します。
allowed-tools: Read, Glob, Grep, Task, Write, TodoWrite, Bash
argument-hint: "[要件名]"
---
Kairo開発の前にコンテキスト情報を収集し、開発に必要な情報をノートファイルにまとめます。

# context

出力ディレクトリ="docs/spec"
要件名={{requirement_name}}
収集情報=[]

# step

- $ARGUMENTS がない場合、「引数に要件名を指定してください（例: ユーザー認証システム）」と言って終了する
- $ARGUMENTS の内容と context の内容をまとめてユーザに宣言する
- step2 を実行する

## step2: 既存ノートの確認

- `{{出力ディレクトリ}}/{要件名}/note.md` が既にある場合:
  - 既存ファイルの内容を表示
  - 終了する
- 存在しない場合: step3 を実行する

## step3: 開発コンテキストの収集

### Phase 1: プロジェクト基本情報の収集

**追加ルールの読み込み**
- `CLAUDE.md` ファイルが存在する場合は読み込み（技術スタック・制約）
- `AGENTS.md` ファイルが存在する場合は読み込み
- `README.md` が存在する場合は読み込み
- `docs/rule` ディレクトリが存在する場合は読み込み
- `docs/rule/kairo` ディレクトリが存在する場合は読み込み
- 各ディレクトリ内のすべてのファイルを読み込み、追加ルールとして適用

### Phase 2: 既存設計文書・仕様書の収集

**既存の要件定義・設計書の検索**
- `docs/spec/{要件名}-requirements.md`: 統合機能要件
- `docs/spec/{要件名}-user-stories.md`: 詳細なユーザストーリー
- `docs/spec/{要件名}-acceptance-criteria.md`: 受け入れ基準
- `docs/spec/{要件名}-*.md`: その他関連ドキュメント
- `docs/design/*.md`: 設計文書ディレクトリ
- `docs/tech-stack.md`: 技術スタック
- 見つかったファイルをすべて Read ツールで読み込み

### Phase 3: 既存実装の調査（オプション）

- ユーザーに確認: 「既存コードベースの詳細分析が必要ですか？（y/n）」
- 必要な場合のみ実行:
  - **Task tool (subagent_type: Explore, thoroughness: medium) を使用して実装関連情報を探索**
    - 類似機能の実装例を探索
    - ユーティリティ関数・共通モジュールを探索
    - 実装パターンやアーキテクチャガイドラインを特定
    - 依存関係やインポートパスを確認

### Phase 4: Git情報の収集

- `git status` で現在の開発状況を確認
- `git log --oneline -20` で最近のコミット履歴を確認
- 既存のブランチ情報を確認

### Phase 5: プロジェクト構造の把握

- ディレクトリ構造を把握（主要ディレクトリのみ）
- 設定ファイルの確認（package.json, tsconfig.json等）

- step4 を実行する

## step4: 収集情報の整理と保存

- 収集した情報を <note_template> の形式で整理
- 以下の内容を含める:
  1. **プロジェクト概要**
  2. **技術スタック**
  3. **開発ルール**
  4. **既存の要件定義**
  5. **既存の設計文書**
  6. **関連実装**（オプション）
  7. **技術的制約**
  8. **注意事項**

- Write ツールを使用して `{{出力ディレクトリ}}/{要件名}/note.md` に保存
- step5 を実行する

## step5: 完了報告

- TodoWrite ツールで TODO ステータスを更新する
  - 現在のTODOを「completed」にマーク
  - コンテキスト収集フェーズの完了をTODO内容に反映
  - 次のフェーズ「要件定義作成」をTODOに追加

- 完了報告を表示：
  - 収集したファイルの一覧
  - プロジェクトの概要サマリー
  - 作成したノートファイルのパス

# rules

## ファイル名のルール

### 出力ファイルのパス形式
- `docs/spec/{要件名}/note.md`
- 例: `docs/spec/user-auth-system/note.md`

### ディレクトリ作成
- `docs/spec/{要件名}/` ディレクトリが存在しない場合は自動作成
- 必要に応じて親ディレクトリも作成

### ファイル名の命名規則
- 要件名を簡潔な英語に変換する
- ケバブケース（kebab-case）を使用
- 最大50文字程度に収める
- 例:
  - "ユーザー認証システム" → "user-auth-system"
  - "データエクスポート機能" → "data-export"
  - "パスワードリセット" → "password-reset"

## ファイルパスの記載ルール

- **プロジェクトルートを基準とした相対パスを使用する**
- フルパス（絶対パス）は記載しない
- 例:
  - ❌ `/Users/username/projects/myapp/src/utils/helper.ts`
  - ✅ `src/utils/helper.ts`

## 情報収集の優先順位

1. **必須**: CLAUDE.md, README.md, 既存の要件定義・設計書
2. **推奨**: 追加ルール、設定ファイル、Git情報
3. **オプション**: 既存実装の詳細分析

## TODO更新パターン

```
- 現在のTODOを「completed」にマーク
- コンテキスト収集フェーズの完了をTODO内容に反映
- 次のフェーズ「要件定義作成」をTODOに追加
```

# info

<note_template>
# {要件名} 開発コンテキストノート

## 作成日時
{作成日時}

## プロジェクト概要

### プロジェクト名
{プロジェクト名}

### プロジェクトの目的
{プロジェクトの目的・概要}

**参照元**: {README.md または CLAUDE.md のパス}

## 技術スタック

### 使用技術・フレームワーク
- **言語**: {プログラミング言語}
- **フレームワーク**: {使用フレームワーク}
- **ランタイム**: {Node.js, Python等}
- **パッケージマネージャー**: {npm, yarn, pip等}

### アーキテクチャパターン
- **アーキテクチャスタイル**: {MVC, クリーンアーキテクチャ, マイクロサービス等}
- **設計パターン**: {使用している設計パターン}
- **ディレクトリ構造**: {プロジェクトの構造}

**参照元**:
- [CLAUDE.md](CLAUDE.md)
- [architecture.md](docs/design/architecture.md)

## 開発ルール

### プロジェクト固有のルール
{プロジェクト固有の開発ルール}

### コーディング規約
- **命名規則**: {命名規則の詳細}
- **型チェック**: {TypeScript strict mode等}
- **コメント**: {コメントのルール}
- **フォーマット**: {Prettier, ESLint等の設定}

### テスト要件
- **テストフレームワーク**: {Jest, Pytest等}
- **カバレッジ要件**: {最低カバレッジ率}
- **テストパターン**: {AAA, Given-When-Then等}

**参照元**:
- [AGENTS.md](AGENTS.md)
- [docs/rule/](docs/rule/)
- [docs/rule/kairo/](docs/rule/kairo/)

## 既存の要件定義

### 要件定義書
{既存の要件定義の要約}

**参照元**:
- [requirements.md](docs/spec/{要件名}-requirements.md)
- [user-stories.md](docs/spec/{要件名}-user-stories.md)
- [acceptance-criteria.md](docs/spec/{要件名}-acceptance-criteria.md)

### 主要な機能要件（EARS記法）
- REQ-001: {要件の概要}
- REQ-002: {要件の概要}
- ...

### 主要な非機能要件
- NFR-001: {パフォーマンス要件}
- NFR-101: {セキュリティ要件}
- ...

## 既存の設計文書

### アーキテクチャ設計
{アーキテクチャの要約}

**参照元**: [architecture.md](docs/design/architecture.md)

### データフロー
{データフローの要約}

**参照元**: [dataflow.md](docs/design/dataflow.md)

### TypeScript型定義
{主要な型定義の要約}

**参照元**: [interfaces.ts](docs/design/interfaces.ts)

### データベース設計
{DBスキーマの要約}

**参照元**: [database-schema.sql](docs/design/database-schema.sql)

### API仕様
{APIエンドポイントの要約}

**参照元**: [api-endpoints.md](docs/design/api-endpoints.md)

## 関連実装

### 類似機能の実装例
{既存の類似実装の参照先}

**参照元**:
- [{ファイルパス1}]({ファイルパス1})
- [{ファイルパス2}]({ファイルパス2})

### 参考パターン
{実装パターンの要約}

### 共通モジュール・ユーティリティ
{使用可能な共通機能}

**参照元**:
- [{ユーティリティファイル1}]({ユーティリティファイル1})
- [{ユーティリティファイル2}]({ユーティリティファイル2})

### 依存関係・インポートパス
{重要な依存関係の情報}

## 技術的制約

### パフォーマンス制約
- {パフォーマンス要件の詳細}

### セキュリティ制約
- {セキュリティ要件の詳細}

### 互換性制約
- {ブラウザ互換性、バージョン制約等}

### データ制約
- {データサイズ、形式等の制約}

**参照元**: [CLAUDE.md](CLAUDE.md)

## 注意事項

### 開発時の注意点
- {開発時に注意すべき事項}

### デプロイ・運用時の注意点
- {デプロイ・運用時の注意事項}

### セキュリティ上の注意点
- {セキュリティ関連の注意事項}

### パフォーマンス上の注意点
- {パフォーマンス関連の注意事項}

## Git情報

### 現在のブランチ
{現在のブランチ名}

### 最近のコミット
{最近のコミット履歴（抜粋）}

### 開発状況
{現在の開発状況のサマリー}

## 収集したファイル一覧

### プロジェクト基本情報
- [CLAUDE.md](CLAUDE.md)
- [README.md](README.md)
- [AGENTS.md](AGENTS.md)

### 追加ルール
- [docs/rule/](docs/rule/)
- [docs/rule/kairo/](docs/rule/kairo/)

### 要件定義・仕様書
- [docs/spec/{要件名}-requirements.md](docs/spec/{要件名}-requirements.md)
- [docs/spec/{要件名}-user-stories.md](docs/spec/{要件名}-user-stories.md)
- [docs/spec/{要件名}-acceptance-criteria.md](docs/spec/{要件名}-acceptance-criteria.md)

### 設計文書
- [docs/design/architecture.md](docs/design/architecture.md)
- [docs/design/dataflow.md](docs/design/dataflow.md)
- [docs/design/interfaces.ts](docs/design/interfaces.ts)
- [docs/design/database-schema.sql](docs/design/database-schema.sql)
- [docs/design/api-endpoints.md](docs/design/api-endpoints.md)

### 関連実装（オプション）
- [{実装ファイル1}]({実装ファイル1})
- [{実装ファイル2}]({実装ファイル2})

---

**注意**: すべてのファイルパスはプロジェクトルートからの相対パスで記載しています。
</note_template>
