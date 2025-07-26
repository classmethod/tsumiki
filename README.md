# Tsumiki - AI駆動開発支援フレームワーク

TsumikiはAI駆動開発のためのフレームワークです。要件定義から実装まで、AIを活用した効率的な開発プロセスを提供します。

## 概要

Tsumikiは以下の2つのコマンドで構成されています：

- **kairo** - 要件定義から実装までの包括的な開発フロー
- **tdd** - テスト駆動開発（TDD）の個別実行

### Kairoコマンド

Kairoは要件定義から実装までの開発プロセスを自動化・支援します。以下の開発フローを支援します：

1. **要件展開** - 概要から詳細な要件定義書を生成
2. **設計** - 技術設計文書を自動生成
3. **タスク分割** - 実装タスクを適切に分割・順序付け
4. **TDD実装** - テスト駆動開発による品質の高い実装

## インストール

このリポジトリには既にTsumikiコマンドがインストールされています。
`.claude/commands/` ディレクトリに以下のコマンドが含まれています：

### Kairoコマンド（包括的開発フロー）
- `kairo-requirements.md` - 要件展開
- `kairo-design.md` - 設計文書生成
- `kairo-tasks.md` - タスク分割
- `kairo-implement.md` - 実装実行

### TDDコマンド（個別実行）
- `tdd-requirements.md` - TDD要件定義
- `tdd-testcases.md` - テストケース作成
- `tdd-red.md` - テスト実装（Red）
- `tdd-green.md` - 最小実装（Green）
- `tdd-refactor.md` - リファクタリング
- `tdd-verify-complete.md` - 品質確認

## 使用方法

### TDDコマンド

個別にTDDプロセスを実行したい場合は、以下のコマンドを順次実行できます：

```bash
# TDD要件定義
$ claude code tdd-requirements

# テストケース作成
$ claude code tdd-testcases

# テスト実装（Red）
$ claude code tdd-red

# 最小実装（Green）
$ claude code tdd-green

# リファクタリング
$ claude code tdd-refactor

# 品質確認
$ claude code tdd-verify-complete
```

### Kairoコマンド（包括的フロー）

#### 1. 要件定義

最初に、プロジェクトの要件概要をKairoに伝えます：

```bash
$ claude code kairo-requirements

# プロンプト例：
# "ECサイトの商品レビュー機能を実装したい。
#  ユーザーは商品に対して5段階評価とコメントを投稿でき、
#  他のユーザーのレビューを参照できる。"
```

Kairoは以下を生成します：
- ユーザーストーリー
- EARS記法による詳細な要件定義
- エッジケースの考慮
- 受け入れ基準

生成されたファイル: `/docs/spec/{要件名}-requirements.md`

### 2. 設計

要件を確認・修正した後、設計を依頼します：

```bash
$ claude code kairo-design

# 要件を承認済みであることを伝えてください
```

Kairoは以下を生成します：
- アーキテクチャ設計書
- データフロー図（Mermaid）
- TypeScriptインターフェース定義
- データベーススキーマ
- APIエンドポイント仕様

生成されたファイル: `/docs/design/{要件名}/` 配下

### 3. タスク分割

設計を確認した後（承認は省略可）、タスク分割を実行します：

```bash
$ claude code kairo-tasks

# 設計を承認したことを伝えてください（または省略可能）
```

Kairoは以下を生成します：
- 依存関係を考慮したタスク一覧
- 各タスクの詳細（テスト要件、UI/UX要件含む）
- 実行順序とスケジュール

生成されたファイル: `/docs/tasks/{要件名}-tasks.md`

### 4. 実装

タスクを確認した後、実装を開始します：

```bash
# 全タスクを順番に実装
$ claude code kairo-implement

# 特定のタスクのみ実装
$ claude code kairo-implement
# "TASK-101を実装してください"
```

Kairoは各タスクに対して内部的にTDDコマンドを使用して以下のプロセスを実行します：
1. 詳細要件定義（tdd-requirements）
2. テストケース作成（tdd-testcases）
3. テスト実装（tdd-red）
4. 最小実装（tdd-green）
5. リファクタリング（tdd-refactor）
6. 品質確認（tdd-verify-complete）

## ディレクトリ構造

```
./
├── .claude/
│   └── commands/           # Kairoコマンド
├── docs/
│   ├── spec/              # 要件定義書
│   ├── design/            # 設計文書
│   └── tasks/             # タスク一覧
├── implementation/        # 実装コード
│   └── {要件名}/
│       └── {タスクID}/
├── backend/              # バックエンドコード
├── frontend/             # フロントエンドコード
└── database/             # データベース関連
```

## ワークフロー例

```mermaid
flowchart TD
    A[要件概要を伝える] --> B[kairo-requirements]
    B --> C{要件を確認}
    C -->|修正必要| B
    C -->|OK| D[kairo-design]
    D --> E{設計を確認}
    E -->|修正必要| D
    E -->|OK| F[kairo-tasks]
    F --> G{タスクを確認}
    G -->|OK| H[kairo-implement]
    H --> I{全タスク完了?}
    I -->|No| H
    I -->|Yes| J[プロジェクト完了]
```

## 利点

1. **一貫性のある開発プロセス**
   - 要件から実装まで統一されたフロー
   - EARS記法による明確な要件定義

2. **品質の担保**
   - TDDコマンドによる堅牢な実装
   - 包括的なテストカバレッジ

3. **効率的な開発**
   - 自動的なタスク分割と優先順位付け
   - 依存関係の可視化

4. **包括的なドキュメント**
   - 要件、設計、実装が全てドキュメント化
   - 後からの参照が容易

## 注意事項

- 各ステップでユーザーの確認を求めます
- 生成された内容は必ずレビューしてください
- プロジェクトの特性に応じて調整が必要な場合があります

## トラブルシューティング

### Q: 要件が複雑すぎる場合は？
A: 要件を複数の小さな機能に分割して、それぞれに対してKairoを実行してください。

### Q: 既存のコードベースに適用できる？
A: はい。既存のコードを分析した上で、新機能の追加や改修に使用できます。

### Q: カスタマイズは可能？
A: 各コマンドファイルを編集することで、プロジェクトに合わせたカスタマイズが可能です。

## サポート

問題や質問がある場合は、プロジェクトのイシュートラッカーに報告してください。
