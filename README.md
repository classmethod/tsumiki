# Tsumiki - AI駆動開発支援フレームワーク

TsumikiはAI駆動開発のためのフレームワークです。要件定義から実装まで、AIを活用した効率的な開発プロセスを提供します。

## インストール

Tsumikiを使用するには、次のnpxコマンドでインストールしてください：

```bash
npx tsumiki install
```

デフォルトでは、`.claude/commands/` にTsumikiのClaude Codeスラッシュコマンドがインストールされます。
Qwen3 Coder を使用する場合は、以下のように `--target` オプションを指定してください：

```bash
npx tsumiki install --target qwen
```

または、設定ファイル (`.tsumikirc`) を使用してデフォルトのターゲットを指定することもできます。

## アンインストール

Tsumikiをアンインストールするには、次のコマンドを使用してください：

```bash
npx tsumiki uninstall
```

Qwen3 Coder環境からアンインストールする場合は、`--target` オプションを指定してください：

```bash
npx tsumiki uninstall --target qwen
```

設定ファイル（`.tsumikirc`）でターゲットを指定している場合は、オプションなしでも適切な環境からアンインストールされます。

### 設定ファイル

プロジェクトのルートディレクトリに `.tsumikirc` ファイルを作成し、以下のように記述することで、
コマンドラインオプションを指定しなくても、指定したCoder環境にインストールできます。

例: `.tsumikirc`
```toml
target = "qwen"
```

## 概要

Tsumikiは以下の2つのコマンドで構成されています：

- **kairo** - 要件定義から実装までの包括的な開発フロー
- **tdd** - テスト駆動開発（TDD）の個別実行

### Kairoコマンド

Kairoは要件定義から実装までの開発プロセスを自動化・支援します。以下の開発フローを支援します：

1. **要件定義** - 概要から詳細な要件定義書を生成
2. **設計** - 技術設計文書を自動生成
3. **タスク分割** - 実装タスクを適切に分割・順序付け
4. **TDD実装** - テスト駆動開発による品質の高い実装

## 利用可能なコマンド

### Kairoコマンド（包括的開発フロー）
- `kairo-requirements` - 要件定義
- `kairo-design` - 設計文書生成
- `kairo-tasks` - タスク分割
- `kairo-implement` - 実装実行

### TDDコマンド（個別実行）
- `tdd-requirements` - TDD要件定義
- `tdd-testcases` - テストケース作成
- `tdd-red` - テスト実装（Red）
- `tdd-green` - 最小実装（Green）
- `tdd-refactor` - リファクタリング
- `tdd-verify-complete` - TDD完了確認

### リバースエンジニアリングコマンド
- `rev-tasks` - 既存コードからタスク一覧を逆生成
- `rev-design` - 既存コードから設計文書を逆生成
- `rev-specs` - 既存コードからテスト仕様書を逆生成
- `rev-requirements` - 既存コードから要件定義書を逆生成

## クイックスタート

### 包括的な開発フロー

```bash
# 1. 要件定義
/kairo-requirements

# 2. 設計
/kairo-design

# 3. タスク分割
/kairo-tasks

# 4. 実装
/kairo-implement
```

### 個別TDDプロセス

```bash
/tdd-requirements
/tdd-testcases
/tdd-red
/tdd-green
/tdd-refactor
/tdd-verify-complete
```

### リバースエンジニアリング

```bash
# 1. 既存コードからタスク構造を分析
/rev-tasks

# 2. 設計文書の逆生成（タスク分析後推奨）
/rev-design

# 3. テスト仕様書の逆生成（設計文書後推奨）
/rev-specs

# 4. 要件定義書の逆生成（全分析完了後推奨）
/rev-requirements
```

### 開発環境のクリーンアップ

```bash
# 開発環境をクリーンアップ
/clear
```

## 詳細なマニュアル

使用方法の詳細、ディレクトリ構造、ワークフロー例、トラブルシューティングについては [MANUAL.md](./MANUAL.md) を参照してください。
