---
description: プロジェクトの初期設定として技術スタックの選定をします。既にCLAUDE.mdがある場合は省略できます
---

# init-tech-stack

## 目的

ユーザとのインタラクティブなやりとりを通じて、プロジェクトに最適な技術スタック定義を作成し、`docs/tech-stack.md` ファイルを生成します。

## 前提条件

- プロジェクトルートディレクトリで実行
- `docs/` ディレクトリが存在する（なければ作成）

## 実行フロー

このコマンドは、**AskUserQuestionツール**を使用して段階的にヒアリングを行います。

### Phase 1: プロジェクト基本情報の収集

まず、以下の3つの質問をAskUserQuestionツールで同時に提示してください：

```
AskUserQuestion({
  questions: [
    {
      question: "プロジェクトのタイプを教えてください",
      header: "プロジェクト",
      multiSelect: false,
      options: [
        { label: "Webアプリケーション", description: "ブラウザで動作するアプリケーション" },
        { label: "モバイルアプリ", description: "スマートフォン/タブレット向けアプリ" },
        { label: "API/バックエンド", description: "API提供がメインのサービス" },
        { label: "デスクトップアプリ", description: "PC向けネイティブアプリ" },
        { label: "ライブラリ/SDK", description: "他の開発者向けのツール" },
        { label: "フルスタック", description: "フロントエンドとバックエンドの両方" }
      ]
    },
    {
      question: "開発チームの規模を教えてください",
      header: "チーム規模",
      multiSelect: false,
      options: [
        { label: "個人開発", description: "1人で開発" },
        { label: "小規模チーム", description: "2-5人" },
        { label: "中規模チーム", description: "6-15人" },
        { label: "大規模チーム", description: "16人以上" }
      ]
    },
    {
      question: "予定している開発期間はどの程度ですか？",
      header: "開発期間",
      multiSelect: false,
      options: [
        { label: "プロトタイプ/MVP", description: "1-2ヶ月" },
        { label: "短期プロジェクト", description: "3-6ヶ月" },
        { label: "中期プロジェクト", description: "6ヶ月-1年" },
        { label: "長期プロジェクト", description: "1年以上" }
      ]
    }
  ]
})
```

### Phase 2: 技術制約・要件の収集

次に、以下の3つの質問をAskUserQuestionツールで同時に提示してください：

```
AskUserQuestion({
  questions: [
    {
      question: "既存のシステムやデータベースとの連携はありますか？",
      header: "既存連携",
      multiSelect: false,
      options: [
        { label: "新規構築", description: "全て新しく作成" },
        { label: "既存DB連携", description: "既存データベースを使用" },
        { label: "既存API連携", description: "既存のAPIと連携" },
        { label: "レガシー移行", description: "既存システムからの移行" }
      ]
    },
    {
      question: "想定される負荷や性能要件を教えてください",
      header: "パフォーマンス",
      multiSelect: false,
      options: [
        { label: "軽負荷", description: "同時利用者数10人以下、レスポンス3秒以内" },
        { label: "中負荷", description: "同時利用者数100人程度、レスポンス1秒以内" },
        { label: "高負荷", description: "同時利用者数1000人以上、レスポンス0.5秒以内" },
        { label: "未定/不明", description: "まだ詳細は決まっていない" }
      ]
    },
    {
      question: "セキュリティの重要度を教えてください",
      header: "セキュリティ",
      multiSelect: false,
      options: [
        { label: "基本レベル", description: "一般的なWebセキュリティ対策" },
        { label: "高度", description: "個人情報取り扱い、金融系など" },
        { label: "エンタープライズ", description: "企業向け、コンプライアンス要件あり" },
        { label: "未定/不明", description: "まだ詳細は決まっていない" }
      ]
    }
  ]
})
```

### Phase 3: チーム・スキル状況の収集

次に、以下の2つの質問をAskUserQuestionツールで同時に提示してください：

```
AskUserQuestion({
  questions: [
    {
      question: "チームメンバーの技術経験を教えてください（複数選択可）",
      header: "技術スキル",
      multiSelect: true,
      options: [
        { label: "JavaScript/TypeScript", description: "経験豊富" },
        { label: "Python", description: "経験豊富" },
        { label: "Java/Kotlin", description: "経験豊富" },
        { label: "C#/.NET", description: "経験豊富" },
        { label: "Go/Rust", description: "経験豊富" },
        { label: "React/Vue/Angular", description: "経験豊富" },
        { label: "データベース設計", description: "経験豊富" },
        { label: "クラウド(AWS/Azure/GCP)", description: "経験豊富" },
        { label: "Docker/Kubernetes", description: "経験豊富" },
        { label: "技術スキル限定的", description: "学習しながら進めたい" }
      ]
    },
    {
      question: "新しい技術の習得についてどう考えますか？",
      header: "学習コスト",
      multiSelect: false,
      options: [
        { label: "積極的に新技術", description: "最新技術でチャレンジしたい" },
        { label: "バランス重視", description: "新技術と安定技術のバランス" },
        { label: "安定技術優先", description: "枯れた技術で確実に開発" },
        { label: "既存スキル活用", description: "チームの知識を最大限活用" }
      ]
    }
  ]
})
```

### Phase 4: 運用・インフラ要件の収集

最後に、以下の2つの質問をAskUserQuestionツールで同時に提示してください：

```
AskUserQuestion({
  questions: [
    {
      question: "アプリケーションをどこで動かす予定ですか？",
      header: "ホスティング",
      multiSelect: false,
      options: [
        { label: "クラウド", description: "AWS/Azure/GCP" },
        { label: "PaaS", description: "Vercel/Netlify/Heroku" },
        { label: "VPS/専用サーバー", description: "自前サーバー" },
        { label: "オンプレミス", description: "社内サーバー" },
        { label: "未定", description: "まだ決まっていない" }
      ]
    },
    {
      question: "開発・運用コストについて教えてください",
      header: "予算制約",
      multiSelect: false,
      options: [
        { label: "コスト最小化", description: "無料・低コストツール優先" },
        { label: "バランス重視", description: "適度なコストは許容" },
        { label: "品質重視", description: "コストより品質・効率を優先" },
        { label: "予算潤沢", description: "最適なツールを選択可能" }
      ]
    }
  ]
})
```

## 技術スタック推奨ロジック

全ての回答を収集した後、以下のロジックで技術を推奨してください：

### フロントエンド選択ロジック

```
IF プロジェクトタイプ == "Webアプリケーション" OR "フルスタック"
  IF チーム経験に "React/Vue/Angular" あり
    IF 学習コスト許容度 == "積極的に新技術"
      推奨: React 19 + TypeScript 5.7+ + Vite 6 (最新技術)
    ELSE
      推奨: React 18.3 + TypeScript 5.7+ + Vite 6 (安定性重視)
  ELSE IF "JavaScript/TypeScript" 経験あり
    推奨: Vue 3.5+ + TypeScript 5.7+ + Vite 6 (学習コスト低)
  ELSE
    推奨: Next.js 15 + TypeScript 5.7+ (フルスタック簡単)
```

### バックエンド選択ロジック

```
IF "JavaScript/TypeScript" 経験豊富
  IF 学習コスト許容度 == "積極的に新技術"
    推奨: Node.js 22 LTS + Fastify 5 + TypeScript 5.7+ (高速)
  ELSE
    推奨: Node.js 22 LTS + Express 5 + TypeScript 5.7+ (安定)
ELSE IF "Python" 経験豊富
  IF パフォーマンス要件 == "高負荷"
    推奨: FastAPI 0.115+ (Python 3.12+) (高速API)
  ELSE
    推奨: Django 5.1+ (Python 3.12+) (フルフィーチャー)
ELSE IF "Java/Kotlin" 経験豊富
  推奨: Spring Boot 3.4+ (Kotlin 2.1+, Java 21+)
ELSE IF "C#/.NET" 経験豊富
  推奨: ASP.NET Core 9 (.NET 9)
ELSE IF "Go/Rust" 経験豊富
  推奨: Go 1.23+ (Gin 1.10+ / Fiber 3) または Rust 1.83+ (Actix-web 4)
ELSE
  推奨: Node.js 22 LTS + Express 5 (フロントエンドとの統一)
```

### データベース選択ロジック

```
IF パフォーマンス要件 == "高負荷"
  推奨: PostgreSQL 17+ + Redis 7.4+ (スケーラビリティ)
ELSE IF セキュリティ要件 == "高度" OR "エンタープライズ"
  推奨: PostgreSQL 17+ (ACID準拠、堅牢)
ELSE IF プロジェクト規模 == "個人開発" AND 開発期間 == "プロトタイプ/MVP"
  推奨: SQLite 3.47+ → PostgreSQL 17+ (段階移行)
ELSE
  推奨: PostgreSQL 17+ (汎用的)
```

### 開発環境・ツール選択ロジック

```
コンテナ:
  推奨: Docker 27+ + Docker Compose v2 (全プロジェクト共通)

パッケージマネージャー:
IF 言語 == "Python"
  推奨: uv (最速・モダン)
ELSE IF 言語 == "Node.js/TypeScript"
  推奨: pnpm 9+ (高速・ディスク効率)
ELSE IF 言語 == "Java/Kotlin"
  推奨: Gradle 8.12+ (Kotlin DSL)

テストツール:
IF フロントエンド == React系 AND ビルドツール == Vite
  推奨: Vitest 2+ + Testing Library (高速統合)
ELSE IF フロントエンド == Vue系
  推奨: Vitest 2+ + Vue Test Utils
ELSE IF バックエンド == Python
  推奨: pytest 8+ + pytest-asyncio
ELSE IF バックエンド == Java/Kotlin
  推奨: JUnit 5 + Kotest

E2Eテスト:
  推奨: Playwright 1.49+ (全言語対応・高速・信頼性高)

リンター・フォーマッター:
IF 言語 == "Python"
  推奨: Ruff 0.8+ (最速オールインワン)
ELSE IF 言語 == "TypeScript/JavaScript"
  推奨: Biome 1.9+ (最速) または ESLint 9+ + Prettier 3+
ELSE IF 言語 == "Kotlin"
  推奨: ktlint 1.5+ + detekt 1.23+
```

## 推奨結果の表示

全ての回答に基づいて、以下の形式で推奨結果をマークダウンで表示してください：

```markdown
# あなたの回答に基づく技術スタック推奨

## 📋 回答サマリー
- プロジェクトタイプ: [回答]
- チーム規模: [回答]
- 開発期間: [回答]
- 既存連携: [回答]
- パフォーマンス: [回答]
- セキュリティ: [回答]
- 技術スキル: [回答（複数の場合はカンマ区切り）]
- 学習コスト許容度: [回答]
- ホスティング: [回答]
- 予算: [回答]

## 🚀 推奨技術スタック

### フロントエンド
✅ **[推奨技術]**
   - 理由: [選択理由]
   - メリット: [メリット]
   - 学習コスト: [低/中/高]

⚠️ **[代替案]** （代替案）
   - 理由: [選択理由]
   - メリット: [メリット]
   - 学習コスト: [低/中/高]

### バックエンド
✅ **[推奨技術]**
   - 理由: [選択理由]
   - メリット: [メリット]
   - 学習コスト: [低/中/高]

### データベース
✅ **[推奨技術]**
   - 理由: [選択理由]
   - メリット: [メリット]
   - 学習コスト: [低/中/高]

### 開発環境・ツール
✅ **[コンテナ技術]**
✅ **[テストツール]**
✅ **[E2Eテスト]**
✅ **[リンター・フォーマッター]**: ESLint + Prettier

## ⚙️ 整合性チェック

✅ **技術選択の整合性**: [問題なし/要確認]
- [整合性の説明]

✅ **チームスキルとのマッチング**: [良好/要学習あり]
- [マッチング状況の説明]

✅ **プロジェクト要件との適合性**: [適合/一部要調整]
- [適合性の説明]
```

## 最終確認

推奨結果を表示した後、以下の質問をAskUserQuestionツールで提示してください：

```
AskUserQuestion({
  questions: [
    {
      question: "この推奨で進めますか？",
      header: "最終確認",
      multiSelect: false,
      options: [
        { label: "はい", description: "この推奨でdocs/tech-stack.mdを生成" },
        { label: "一部変更したい", description: "個別技術を調整" },
        { label: "やり直し", description: "ヒアリングからやり直す" }
      ]
    }
  ]
})
```

### 「はい」を選択された場合

`docs/tech-stack.md` ファイルを生成してください。テンプレートは以下の通り：

```markdown
# プロジェクト技術スタック定義

## 🔧 生成情報
- **生成日**: [YYYY-MM-DD]
- **生成ツール**: init-tech-stack
- **プロジェクトタイプ**: [回答]
- **チーム規模**: [回答]
- **開発期間**: [回答]

## 🎯 プロジェクト要件サマリー
- **パフォーマンス**: [回答]
- **セキュリティ**: [回答]
- **技術スキル**: [回答]
- **学習コスト許容度**: [回答]
- **デプロイ先**: [回答]
- **予算**: [回答]

## 🚀 フロントエンド
- **フレームワーク**: [技術名とバージョン]
- **言語**: [言語とバージョン]
- **状態管理**: [選択されたツール]
- **バンドラー**: [選択されたツール]
- **ルーティング**: [選択されたツール]

### 選択理由
- [理由1]
- [理由2]
- [理由3]

## ⚙️ バックエンド
- **フレームワーク**: [技術名とバージョン]
- **言語**: [言語とバージョン]
- **データベース**: [データベース名とバージョン]
- **ORM**: [選択されたツール]
- **認証**: [選択された方式]
- **キャッシュ**: [選択されたツール（必要な場合）]

### 選択理由
- [理由1]
- [理由2]
- [理由3]

## 💾 データベース設計
- **メインDB**: [データベース名とバージョン]
- **キャッシュ**: [キャッシュツール（必要な場合）]
- **ファイルストレージ**: [ストレージ戦略]

### 設計方針
- [方針1]
- [方針2]
- [方針3]

## 🛠️ 開発環境
- **コンテナ**: Docker + Docker Compose
- **パッケージマネージャー**:
  - Python: uv (高速・モダン)
  - Node.js: pnpm (高速・ディスク効率)
  - Java/Kotlin: Gradle (Kotlin DSL)
- **ランタイムバージョン**: [バージョン情報]

### 開発ツール
- **テストフレームワーク**:
  - Python: pytest + pytest-asyncio
  - TypeScript/JavaScript: Vitest (Vite使用時) / Jest (その他)
  - Java/Kotlin: JUnit 5 + Kotest
- **E2Eテスト**: Playwright (全言語対応・高速・信頼性高)
- **リンター・フォーマッター**:
  - Python: Ruff (高速・オールインワン)
  - TypeScript/JavaScript: Biome (高速) / ESLint + Prettier
  - Java/Kotlin: ktlint + detekt
- **型チェック**:
  - Python: mypy
  - TypeScript: tsc (TypeScript Compiler)

### CI/CD
- **CI/CD**: GitHub Actions (推奨)
- **コード品質**: ESLint, Prettier, [型チェック]
- **テスト**: Unit, Integration, E2E
- **デプロイ**: 自動デプロイ with approval

## ☁️ インフラ・デプロイ
- **フロントエンド**: [デプロイ先]
- **バックエンド**: [デプロイ先]
- **データベース**: [DBホスティング]
- **キャッシュ**: [キャッシュホスティング（該当する場合）]
- **CDN**: [CDNサービス（該当する場合）]

## 🔒 セキュリティ
- **HTTPS**: 必須 (証明書自動更新)
- **認証**: [認証方式]
- **CORS**: 適切な設定
- **バリデーション**: サーバーサイドバリデーション
- **環境変数**: 機密情報の適切な管理
- **依存関係**: 定期的な脆弱性チェック

## 📊 品質基準
- **テストカバレッジ**: 80%以上
- **コード品質**: ESLint + Prettier
- **型安全性**: [型安全性要件]
- **パフォーマンス**: Lighthouse 90+点（Web系の場合）
- **アクセシビリティ**: WCAG 2.1 AA準拠（Web系の場合）

## 📁 推奨ディレクトリ構造

```
./ (カレントディレクトリ = プロジェクトルート)
├── frontend/                 # フロントエンド
│   ├── src/
│   │   ├── components/      # Reactコンポーネント
│   │   ├── pages/           # ページコンポーネント
│   │   ├── hooks/           # カスタムフック
│   │   ├── utils/           # ユーティリティ関数
│   │   ├── types/           # TypeScript型定義
│   │   ├── api/             # APIクライアント
│   │   └── App.tsx
│   ├── public/              # 静的ファイル
│   ├── tests/               # テスト
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts       # or next.config.js
│   └── tailwind.config.js
├── backend/                  # バックエンド
│   ├── app/                 # (Python/FastAPI/Djangoの場合)
│   │   ├── main.py          # エントリポイント
│   │   ├── api/             # APIルート
│   │   │   └── v1/
│   │   ├── core/            # 設定・セキュリティ
│   │   ├── models/          # ORMモデル
│   │   ├── schemas/         # スキーマ定義
│   │   ├── services/        # ビジネスロジック
│   │   ├── db/              # データベース接続
│   │   └── utils/           # ユーティリティ
│   ├── src/                 # (Node.js/Java/Kotlin/Go等の場合)
│   │   └── ...
│   ├── tests/               # テスト
│   ├── migrations/          # DBマイグレーション
│   ├── pyproject.toml       # (Python) or package.json (Node.js) or build.gradle.kts (Kotlin)
│   └── Dockerfile
├── docker-compose.yml        # Docker構成
├── .github/
│   └── workflows/           # GitHub Actions
│       ├── ci.yml
│       └── deploy.yml
├── docs/                     # ドキュメント
│   ├── tech-stack.md        # このファイル
│   ├── requirements/        # 要件定義書
│   ├── design/              # 設計書
│   └── tasks/               # タスク管理
├── .env.example             # 環境変数テンプレート
├── .gitignore
└── README.md
```

**重要**: 上記の `./` はカレントディレクトリ（現在作業中のディレクトリ）を指します。新しいディレクトリを作成するのではなく、既存のプロジェクトルートに直接配置してください。

## 🚀 セットアップ手順

### 1. 開発環境準備
```bash
[セットアップコマンド]
```

### 2. 主要コマンド
```bash
[開発に必要な主要コマンド]
```

## 📝 カスタマイズ方法

このファイルはプロジェクトの進行に応じて更新してください：

1. **技術の追加**: 新しいライブラリ・ツールを追加
2. **要件の変更**: パフォーマンス・セキュリティ要件の更新
3. **インフラの変更**: デプロイ先・スケール要件の変更
4. **チーム変更**: メンバー増減に応じた技術選択の見直し

## 🔄 更新履歴
- [生成日]: 初回生成 (init-tech-stackにより自動生成)
```

生成後、以下の確認メッセージを表示してください：

```markdown
✅ 技術スタック定義ファイルを生成しました！

📄 **生成ファイル**: `docs/tech-stack.md`
🎯 **推奨理由**: チーム経験との適合性、プロジェクト要件への最適化

## 次のステップ

1. **ファイル確認**: `docs/tech-stack.md` の内容を確認
2. **カスタマイズ**: 必要に応じて技術選択を微調整
3. **チーム共有**: 技術選択をチームで合意
4. **開発開始**: 他のkairo-*コマンドで要件定義・設計に進む

このファイルは他の全てのコマンド（kairo-*, tdd-*, direct-*）で自動参照されます。
```

### 「一部変更したい」を選択された場合

以下の質問をAskUserQuestionツールで提示してください：

```
AskUserQuestion({
  questions: [
    {
      question: "どの部分を変更しますか？",
      header: "カスタマイズ",
      multiSelect: true,
      options: [
        { label: "フロントエンド", description: "現在: [推奨技術]" },
        { label: "バックエンド", description: "現在: [推奨技術]" },
        { label: "データベース", description: "現在: [推奨技術]" },
        { label: "開発環境・ツール", description: "現在: [推奨技術]" }
      ]
    }
  ]
})
```

選択された部分について、個別に詳細な選択肢を提示し、調整後に再度最終確認を行ってください。

### 「やり直し」を選択された場合

Phase 1から再度ヒアリングを開始してください。

## エラーハンドリング

### 既存ファイルの扱い

`docs/tech-stack.md` が既に存在する場合、以下の質問をAskUserQuestionツールで提示してください：

```
AskUserQuestion({
  questions: [
    {
      question: "docs/tech-stack.mdが既に存在します。どうしますか？",
      header: "既存ファイル",
      multiSelect: false,
      options: [
        { label: "上書き", description: "既存ファイルを上書きする" },
        { label: "バックアップして上書き", description: "既存ファイルを.bakとして保存" },
        { label: "別名で保存", description: "tech-stack-new.mdとして保存" },
        { label: "キャンセル", description: "処理を中止する" }
      ]
    }
  ]
})
```

## 重要な注意事項

1. **AskUserQuestionツールの使用**: 全ての質問はAskUserQuestionツールを使用して提示してください
2. **並列質問**: 関連する質問は同時に提示して効率化してください
3. **回答の保存**: ユーザーの回答は全て保存し、最終的なファイル生成に使用してください
4. **最新バージョン確認**: 技術スタックを推奨する際は、可能な限り最新の安定版バージョンを推奨してください
5. **整合性確認**: 推奨する技術スタック間の整合性を必ず確認してください
