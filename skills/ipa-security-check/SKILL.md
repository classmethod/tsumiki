---
name: ipa-security-check
description: IPA「安全なウェブサイトの作り方 改訂第7版」「安全なSQLの呼び出し方」「ウェブ健康診断仕様」「セキュリティ実装チェックリスト」「安全なウェブサイトの運用管理に向けての20ヶ条」に基づき、ソースコードを静的に検査して脆弱性候補を検出する。発見した問題には IPA 原典の出典 (文書名・章・ページ・URL) を必ず付与する。
---

# IPA Security Check Skill

## このスキルが行うこと

IPA (情報処理推進機構) が公開する以下 5 資料の指摘事項に基づき、ローカルリポジトリのソースコード・設定ファイルを静的検査し、脆弱性候補を検出する。

| 略称 | 正式名称 | 主な検査内容 |
|---|---|---|
| SWS | 安全なウェブサイトの作り方 改訂第7版 | 11脆弱性 (SQLi/OSコマンド/トラバーサル/セッション/XSS/CSRF/HTTPヘッダ/メールヘッダ/クリックジャッキング/BoF/アクセス制御) |
| SQL | 安全なSQLの呼び出し方 | プレースホルダ使い分け・LIKE述語・識別子検証・文字コード問題 |
| WHC | ウェブ健康診断仕様 | 13診断項目のうち静的解析でカバー可能な観点 |
| OPS | 安全なウェブサイトの運用管理に向けての20ヶ条 | HTTPヘッダ・依存ライブラリ・設定ファイル類 |
| CL | セキュリティ実装チェックリスト | 改訂第7版 p.105-108 のチェックリスト |

すべての検出結果に IPA 原典の `document / section / page / url` を必ず添えて返す。

## 起動方法

スラッシュコマンド `/ipa-security-check` で起動する。引数で対象スコープを指定する。

| 形式 | 動作 |
|---|---|
| `/ipa-security-check` | カレント WD 全体をスキャン |
| `/ipa-security-check <path>` | 指定パス/glob のみ (例: `src/`, `**/*.php`) |
| `/ipa-security-check --diff` | 現ブランチと `main` の差分ファイルのみ |
| `/ipa-security-check --categories sqli,xss <path>` | カテゴリ限定 |
| `/ipa-security-check --severity high` | High 以上のみ |
| `/ipa-security-check --output report.md,report.sarif` | 出力ファイル指定 |

自然文 (「IPA のセキュリティチェックをして」など) でも起動する。

## 実行手順 (Claude が行うこと)

1. **`lib/scope_resolver.md`** を読み、引数を解釈して対象ファイル一覧と言語マッピングを作る
2. **`lib/shard_planner.md`** を読み、カテゴリごとにファイル数を数え、閾値超過時は N 分割する
3. **`agents/` 配下** の検査系サブエージェント (14 体) を **メインから並列起動** する (公式制約によりサブエージェントから二次サブエージェントは起動できないため、分割はメイン側で行う)
4. 各サブエージェントは `findings[]` を含む JSON を返す。メインは findings のみ集約してコード本文は文脈に保持せず、`.tmp/ipa-security-check/findings_raw.json` に書き出す
5. **Phase 5 (偽陽性レビュー)**:
   - `scripts/snippet_hash.py` を Bash で実行して `findings_with_hash.json` を作る
   - `15-false-positive-review` エージェントを **5 件 / shard** で並列起動し、返ってきた `verdicts[]` を結合して `verdicts.json` に保存
6. **Phase 6 + 出力 (Step 7)**: `scripts/render_report.py` を Bash で実行する。スクリプトが内部で以下を行う:
   - verdict を `snippet_hash` で findings にマージ
   - 既存 Markdown レポートから triage ブロックを抽出 (`lib/triage_state.md` 準拠) し、`snippet_hash` 一致で新 findings にステータス引き継ぎ
   - `templates/report.md.tmpl` を埋めて Markdown を出力、SARIF 2.1.0 も同時生成
7. デフォルトの保存先は `./security-reports/ipa-security-report-YYYY-MM-DD-NN.md` と `./security-reports/ipa-security-report-YYYY-MM-DD-NN.sarif` (`--output` で上書き可)。`security-reports/` ディレクトリが存在しない場合は自動作成する。同日に複数回実行した場合は連番 (`-01`, `-02`, ...) が自動付与され、既存レポートを上書きしない

中間ファイルの作業ディレクトリは `.tmp/ipa-security-check/` (リポジトリルート直下、名前に `tmp` を含めること)。

詳細な分配ロジックは **`lib/orchestrator.md`** に従う。Claude は `lib/orchestrator.md` を読んでそのとおりに動くこと。

## 対応言語

| 言語 | 拡張子 |
|---|---|
| PHP | `.php` |
| Java | `.java`, `.jsp` |
| Ruby | `.rb`, `.erb` |
| Python | `.py` |
| JavaScript / TypeScript | `.js`, `.jsx`, `.ts`, `.tsx`, `.vue` |
| C# / .NET | `.cs`, `.cshtml`, `.aspx` |
| Go | `.go` |
| 設定ファイル | `.conf`, `nginx.conf`, `.htaccess`, `web.xml`, `*.yaml`, `*.yml`, `Dockerfile` |

## トリアージ (ステータス管理)

検出結果には 4 ステータスを管理できる。状態は Markdown レポート内の HTML コメントブロックに保持され、次回スキャン時に `snippet_hash` で引き継がれる。詳細は `lib/triage_state.md`。

| ステータス | 意味 | 次回スキャンでの扱い |
|---|---|---|
| `未対応` | 未着手 (新規 finding のデフォルト) | 通常表示 |
| `対応する` | 修正予定 / 実施中 | 通常表示 |
| `問題なし` | 確認の上、本物の脆弱性ではない | `## トリアージ済み (抑止)` セクションへ移動。サマリから除外 |
| `保留` | 一旦保留 | `## トリアージ済み (抑止)` セクションへ移動。サマリから除外 |

ユーザーは各 finding 直下の `<!-- ipa-triage:begin ... ipa-triage:end -->` ブロックの `status:` と `note:` を編集する。
`snippet_hash` は `rule_id + file + 正規化された code_snippet` の sha256 で計算するため、行番号が変動しても引き継げる。

### 偽陽性候補

`15-false-positive-review` エージェントが周辺コード/呼び出し元を再評価して `likely_false_positive` と判定した finding は `## 偽陽性候補` セクションへ移動 (本文の検出結果からは除外)。
誤判定と思う場合は対応する triage ブロックの `status:` を `対応する` に変更すると次回スキャンで通常レポートに戻る。

## 誤検知のインライン抑止 (補助)

ソースコードに以下のインラインマーカーを置くと検出段階で finding を生成しない (トリアージとは別軸)。

```
// ipa-skip: IPA-SWS-1-SQLI-001  reason: 内部固定値を埋め込んでいるため
```

`reason:` は必須。

## サブエージェント一覧

`agents/` 配下に 15 体定義。

### 検査エージェント (14 体): Phase 1〜4 で並列起動

| エージェント | 担当 |
|---|---|
| `01-sql-injection` | SQL インジェクション |
| `02-os-command-injection` | OS コマンドインジェクション |
| `03-directory-traversal` | ディレクトリトラバーサル |
| `04-session-management` | セッション管理の不備 |
| `05-xss` | クロスサイトスクリプティング |
| `06-csrf` | クロスサイトリクエストフォージェリ |
| `07-http-header-injection` | HTTP ヘッダインジェクション |
| `08-mail-header-injection` | メールヘッダインジェクション |
| `09-clickjacking` | クリックジャッキング |
| `10-buffer-overflow` | バッファオーバーフロー |
| `11-access-control` | アクセス制御の不備 |
| `safe-sql-details` | 安全な SQL の呼び出し方 深掘り |
| `web-health-check` | ウェブ健康診断 静的解析項目 |
| `operation-checklist` | 運用 20ヶ条 + 実装チェックリスト |

### レビューエージェント (1 体): Phase 5 で並列起動

| エージェント | 担当 |
|---|---|
| `15-false-positive-review` | 検査エージェントの findings に対し周辺コード/呼び出し元を再 Read して偽陽性候補を識別 |

## 出力契約 (検査サブエージェント → メイン)

検査系 (01〜11 / safe-sql-details / web-health-check / operation-checklist) は以下の JSON 形式のみ返す。コード本文や中間ログは返さない。

```json
{
  "agent": "sql-injection",
  "files_scanned": 142,
  "findings": [
    {
      "rule_id": "IPA-SWS-1-SQLI-001",
      "severity": "critical",
      "category": "sql_injection",
      "file": "src/users.php",
      "line": 45,
      "column": 12,
      "code_snippet": "$sql = \"SELECT * FROM users WHERE id = \" . $_GET['id'];",
      "message": "...",
      "ipa": {
        "document": "安全なウェブサイトの作り方 改訂第7版",
        "section": "1.1 SQLインジェクション",
        "page": "6-12",
        "url": "https://www.ipa.go.jp/security/vuln/websecurity/about.html"
      },
      "remediation_type": "根本的解決",
      "remediation": "プレースホルダによる SQL 文の組み立て",
      "cwe": "CWE-89",
      "fix_example": "..."
    }
  ],
  "errors": []
}
```

> `snippet_hash` / `fp_verdict` / `status` などのトリアージ系フィールドは orchestrator (Phase 5・Phase 6) が後付けする。検査エージェントは付与しない。

`15-false-positive-review` の出力契約は `agents/15-false-positive-review.md` を参照。

## ファイル構成

```
.claude/skills/ipa-security-check/
├── SKILL.md                ← 本ファイル (Claude が最初に読む)
├── commands/
│   └── ipa-security-check.md
├── agents/                 ← 15 体のサブエージェント定義
│   ├── 01〜11, safe-sql-details, web-health-check, operation-checklist (検査 14 体)
│   └── 15-false-positive-review.md (偽陽性レビュー)
├── knowledge/              ← IPA 原文ベースの知識 (Skill 単独配布で完結)
├── rules/                  ← YAML 検出シグネチャ
├── templates/              ← Markdown / SARIF テンプレート
├── scripts/                ← Bash 経由で呼ぶ Python 実装
│   ├── snippet_hash.py     ← snippet_hash 計算 (Phase 5 入力準備)
│   └── render_report.py    ← verdict/triage マージ + Markdown/SARIF 出力 (Step 7)
└── lib/
    ├── orchestrator.md
    ├── scope_resolver.md
    ├── shard_planner.md
    ├── triage_state.md     ← ステータス保持・引き継ぎ仕様
    └── output_formatter.md
```

実行時の中間ファイルは `.tmp/ipa-security-check/` 配下に置く (作業ディレクトリ名は必ず `tmp` を含める)。

## 重要な原則

- **IPA 原典への出典明記**: すべての finding に `ipa.document / section / page / url` を必須付与
- **Skill 単独配布**: `knowledge/` `rules/` を Skill 内に同梱。外部の `docs/` を参照しない
- **メイン文脈の節約**: サブエージェントは findings / verdicts JSON のみ返却
- **ネスト禁止準拠**: サブエージェントは二次サブエージェントを起動しない。分割はメイン側で行う
- **偽陽性レビューの分離**: 検出フェーズと FP 判定フェーズは分離する。FP 判定は周辺コードを再 Read して行う
- **トリアージ状態は Markdown 内に保持**: 専用状態ファイルは作らず、レポート自体が状態を持つ (Git で履歴管理可)
- **完全一致抑止**: `snippet_hash` (rule_id + file + 正規化された code_snippet の sha256) で同定する。行番号変動には耐える
