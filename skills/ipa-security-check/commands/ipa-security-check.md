---
name: ipa-security-check
description: IPA 5 資料に基づくソースコード静的セキュリティチェックを実行する
---

# /ipa-security-check

IPA「安全なウェブサイトの作り方 改訂第7版」ほか 4 資料に基づきソースコードを静的検査する。

## 使い方

```
/ipa-security-check [<path>] [--diff] [--categories <list>] [--severity <level>] [--output <files>]
```

## 引数

| 引数 | 必須 | 説明 |
|---|---|---|
| `<path>` | 任意 | スキャン対象パス。ディレクトリまたは glob (例: `src/`, `**/*.php`)。省略時はカレント WD 全体 |
| `--diff` | 任意 | 現ブランチと `main` の差分ファイルのみを対象 |
| `--categories <list>` | 任意 | カンマ区切りでカテゴリ限定。指定可能値: `sqli, oscmd, traversal, session, xss, csrf, http-header, mail-header, clickjacking, bof, access-control, safe-sql, whc, ops` |
| `--severity <level>` | 任意 | 報告下限。`critical, high, medium, low, info` のいずれか。デフォルト `low` |
| `--output <files>` | 任意 | カンマ区切りで出力ファイル指定。デフォルト `security-reports/ipa-security-report-YYYY-MM-DD-NN.md,security-reports/ipa-security-report-YYYY-MM-DD-NN.sarif`（日付・連番自動付与、ディレクトリ自動作成） |

## 使用例

```
# 全体スキャン
/ipa-security-check

# src/ 配下のみ
/ipa-security-check src/

# PHP ファイルのみ
/ipa-security-check '**/*.php'

# main との差分のみ
/ipa-security-check --diff

# SQLi と XSS のみ、High 以上
/ipa-security-check --categories sqli,xss --severity high

# 出力先を指定
/ipa-security-check --output report.md,report.sarif src/
```

## 動作

1. `SKILL.md` の「実行手順」セクションに従う
2. `lib/scope_resolver.md` で対象ファイル列挙
3. `lib/shard_planner.md` でカテゴリ別シャーディング
4. `agents/` 配下の検査サブエージェント (14 体) をメインから並列起動。集約 findings は `.tmp/ipa-security-check/findings_raw.json` に保存
5. **Phase 5**: `scripts/snippet_hash.py` で `snippet_hash` を付与した後、`15-false-positive-review` を **5 件 / shard** で並列起動し、verdicts を `verdicts.json` に集約
6. **Step 7 出力**: `scripts/render_report.py` を Bash で実行。スクリプト内部で verdict マージ・既存レポートからの triage 引き継ぎ・Markdown + SARIF 生成を一括処理

## 出力レポートの 3 セクション

- `## 検出結果` … 通常 (`未対応` / `対応する` のみ)
- `## 偽陽性候補` … FP レビューで `likely_false_positive` 判定 (本文外)
- `## トリアージ済み (抑止)` … `問題なし` / `保留` (サマリから除外)

ユーザーは triage ブロックの `status:` を編集することでセクション間を移動できる。

## 自然文起動

以下のような自然文でもこのコマンドが起動する。

- 「IPA のセキュリティチェックをして」
- 「IPA 安全なウェブサイトの作り方に従ってこのコードを点検して」
- 「IPA の脆弱性チェックを差分で」
