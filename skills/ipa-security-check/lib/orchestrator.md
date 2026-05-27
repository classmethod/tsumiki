# Orchestrator — メイン処理ロジック

このドキュメントはメインの Claude が `/ipa-security-check` 起動時に従う実行ロジックを定義する。

## 全体フロー

```
[Claude main]
   │
   ├─ Step 1: 引数解釈
   │    └─ lib/scope_resolver.md を読んで対象ファイルを列挙
   │
   ├─ Step 2: シャーディング計画
   │    └─ lib/shard_planner.md を読んでカテゴリ x シャード単位の起動計画を作る
   │
   ├─ Step 3: フェーズ別並列起動 (Agent tool)
   │    ├─ Phase 1 (Critical)
   │    ├─ Phase 2 (High)
   │    ├─ Phase 3 (Medium)
   │    └─ Phase 4 (横断系)
   │
   ├─ Step 4: 結果集約
   │    └─ 各エージェントの findings[] を結合し dedupe・severity フィルタ
   │       → .tmp/ipa-security-check/findings_raw.json に保存
   │
   ├─ Step 5: 偽陽性レビュー (Phase 5)
   │    ├─ scripts/snippet_hash.py で findings に snippet_hash 付与
   │    │   → findings_with_hash.json
   │    ├─ findings を再シャーディング (5 件/shard 固定)
   │    ├─ 15-false-positive-review エージェントを並列起動
   │    └─ verdicts[] を結合 → verdicts.json に保存
   │
   ├─ Step 6: (Step 7 の scripts/render_report.py が内部で実施)
   │    ├─ 出力先 Markdown が既存ならパースして prior_state を抽出
   │    └─ snippet_hash 一致で findings にステータスを引き継ぐ
   │
   └─ Step 7: 出力生成
        └─ scripts/render_report.py が verdict マージ・triage マージ・
           Markdown + SARIF 出力を一括で実施
```

---

## Step 1: 引数解釈

`commands/ipa-security-check.md` に定義された引数を解釈する。

### 例

```
/ipa-security-check --categories sqli,xss --severity high src/
```

を以下に分解:

```yaml
scope:
  paths: ["src/"]
  diff_mode: false
filter:
  categories: ["sqli", "xss"]
  severity_min: "high"
output:
  files: ["ipa-security-report.md", "ipa-security-report.sarif"]
```

詳細仕様は `lib/scope_resolver.md`。

---

## Step 2: シャーディング計画

`lib/shard_planner.md` に従い、対象ファイルをカテゴリ x シャード単位に分割する。

例 (PHP ファイル 47 件 + Java ファイル 18 件、shard size = 10):

```yaml
shards:
  - agent: 01-sql-injection
    shard_id: 1
    files: [src/a.php, src/b.php, ...]  # 10 件
  - agent: 01-sql-injection
    shard_id: 2
    files: [...]  # 10 件
  - agent: 01-sql-injection
    shard_id: 3
    files: [...]  # 10 件
  - agent: 01-sql-injection
    shard_id: 4
    files: [...]  # 10 件
  - agent: 01-sql-injection
    shard_id: 5
    files: [src/k.php, ..., src/q.php]  # 7 件
  - agent: 05-xss
    shard_id: 1
    files: [...]
  ...
```

---

## Step 3: フェーズ別並列起動

公式制約により**サブエージェントから二次サブエージェントは起動できない**。よって**メインから全シャードを並列起動**する。

### 並列度の制御

- 1 メッセージ内で `Agent` ツールを複数並列発行できる
- 1 フェーズあたりの**同時起動上限は 8** (デフォルト)
- 8 を超える shard がある場合は、複数フェーズに自然分割する

### フェーズ定義

| フェーズ | カテゴリ | 起動するエージェント |
|---|---|---|
| Phase 1 (Critical) | SQLi / OS コマンド / トラバーサル | `01-sql-injection`, `02-os-command-injection`, `03-directory-traversal` |
| Phase 2 (High) | XSS / CSRF / セッション / HTTP ヘッダ / アクセス制御 | `05-xss`, `06-csrf`, `04-session-management`, `07-http-header-injection`, `11-access-control` |
| Phase 3 (Medium) | メールヘッダ / クリックジャッキング / BoF | `08-mail-header-injection`, `09-clickjacking`, `10-buffer-overflow` |
| Phase 4 (横断系) | SQL 深掘り / 健康診断 / 運用 | `safe-sql-details`, `web-health-check`, `operation-checklist` |

ユーザーが `--categories` で絞った場合は該当エージェントのシャードだけ起動する。

### サブエージェント起動の書式

各シャードは以下の入力で `Agent` ツールに渡す。

```
description: "<agent>-shard-<n> 検査"
subagent_type: "general-purpose"
prompt: <下記の構造化プロンプト>
```

構造化プロンプト (テンプレート):

```
あなたは IPA Security Check Skill の「<agent>」サブエージェントです。
必ず以下の手順で動作してください。

# 1. 検出ルールを読み込む
.claude/skills/ipa-security-check/rules/<rule-file>.yaml を読んでください。

# 2. IPA 原文知識を読み込む
.claude/skills/ipa-security-check/knowledge/<knowledge-file>.md を読んでください。

# 3. 検査対象ファイル (このシャードの担当)
<files をリストで列挙>

# 4. 検査方法
- 各ファイルを Read で開く
- rules の各パターン (regex / ast) で候補を抽出
- 抽出箇所のコード文脈を確認し、誤検知を除く
- 確定した問題箇所のみ JSON の findings[] に積む
- インラインマーカー "ipa-skip: <rule_id>" が直前行にある場合はその指摘を抑制

# 5. 出力
以下の JSON のみ最終出力してください。コード本文や中間ログは返さないでください。

{
  "agent": "<agent>",
  "files_scanned": <N>,
  "findings": [ ... ],
  "errors": [ ... ]
}

findings の各要素は SKILL.md「出力契約」の形式に厳密に従うこと。
ipa.document, ipa.section, ipa.page, ipa.url を必ず埋めること
(値は knowledge/<knowledge-file>.md と rules/<rule-file>.yaml に書いてある)。
```

### 並列発行の例

メイン Claude は 1 つのメッセージ内で複数 `Agent` ツールを同時呼び出す:

```
<Agent> 01-sql-injection-shard-1
<Agent> 01-sql-injection-shard-2
<Agent> 02-os-command-injection-shard-1
<Agent> 03-directory-traversal-shard-1
```

すべて結果が揃ってから次のフェーズへ進む。

---

## Step 4: 結果集約

各シャードの返答 JSON を結合する。メインが直接マージし、結果は作業ファイルに保存:

```python
all_findings = []
for shard_result in results:
    all_findings.extend(shard_result["findings"])

# 重複排除: (file, line, rule_id) をキーに dedupe
# severity フィルタ: filter.severity_min 以下を除外
# 順序: severity 降順 → file 名 → line 番号昇順
```

severity の序列:

```
critical > high > medium > low > info
```

マージ済み配列は `Write` ツールで `.tmp/ipa-security-check/findings_raw.json` へ書き出す。
Step 5 以降のスクリプトはこのファイルを入力にする。

---

## Step 5: 偽陽性レビュー (Phase 5)

Step 4 で集約された findings[] に対し、`15-false-positive-review` エージェントを並列起動して偽陽性候補を識別する。

### 5.1 入力準備

`lib/triage_state.md` の規定で **各 finding の `snippet_hash` を先に計算** する (Phase 5 でも Phase 6 でも使うため orchestrator が一度だけ計算)。
計算ロジックは `scripts/snippet_hash.py` に実装済み。メインは以下を Bash で実行する:

```bash
# 1. 集約済みの findings を作業ファイルに書き出す (Write ツール)
#    → .tmp/ipa-security-check/findings_raw.json
# 2. snippet_hash を付与
python3 .claude/skills/ipa-security-check/scripts/snippet_hash.py \
    .tmp/ipa-security-check/findings_raw.json \
    .tmp/ipa-security-check/findings_with_hash.json
```

作業ディレクトリ命名規約: 中間 JSON はリポジトリルート直下の `.tmp/ipa-security-check/` に置く (名前に `tmp` を含めること)。

### 5.2 シャーディング

findings を **5 件 / shard** で分割する (file サイズではなく件数ベース、固定)。
`shard_planner.md` のロジックは流用せず、ここは件数固定。

FP 判定は各 finding について周辺コード Read + 呼び出し元 Grep を行うため、1 finding あたりのトークン消費が大きい。
シャードあたり 5 件に抑えることで:
- 各サブエージェントの context が膨らみすぎない
- 1 件の重い finding (大きいファイル / 呼び出し元が多い) が他を巻き込まない
- 並列度を稼ぎやすい (20 findings → 4 shards、25 findings → 5 shards)

### 5.3 並列起動

```
description: "false-positive-review-shard-<n>"
subagent_type: "general-purpose"
prompt: <下記>
```

```
あなたは IPA Security Check Skill の「15-false-positive-review」サブエージェントです。
必ず .claude/skills/ipa-security-check/agents/15-false-positive-review.md を読み、
そこに書かれた手順で動作してください。

# このシャードで判定する findings (件)

<JSON 配列をここに展開。各 finding は rule_id / file / line / column / category /
 severity / code_snippet / message / snippet_hash を含む>

# 手順 (要約)
- 各 finding の file を Read で開き、line ±30 行の周辺コードを確認
- 該当箇所が関数内なら関数名を特定し、Grep で呼び出し元最大 10 件を確認
- 代表的な呼び出し元 1〜3 件について引数の出どころを軽く確認
- 偽陽性パターン (静的定数・厳格な検証・型強制・正しいエスケープ・テストコードなど) に該当するか判定

最終出力は agents/15-false-positive-review.md の「出力」セクションの JSON 形式のみ。
コード本文や思考過程は返さないこと。
```

並列度はメイン制約 (1 メッセージ 8 並列) に従う。
例: 40 findings → 8 shards (1 サブフェーズ)、60 findings → 12 shards (8 + 4 の 2 サブフェーズ)。

### 5.4 verdict の集約 (ファイル保存のみ)

各 shard が返した `verdicts[]` を 1 つの JSON 配列に結合し、作業ファイルへ保存する:

```
.tmp/ipa-security-check/verdicts.json
```

`snippet_hash` をキーに finding に書き戻す処理は **Step 7 の `scripts/render_report.py` が一括で行う** ため、メインがここで finding にマージする必要はない。

---

## Step 6: トリアージ状態マージ

`lib/triage_state.md` の規定に従う。Step 7 の `scripts/render_report.py` が以下を自動で実行する:

1. 出力先 Markdown が既に存在すればその内容を読み込み、コードフェンス内の例示ブロックを除外した上で `<!-- ipa-triage:begin ... ipa-triage:end -->` を抽出する
2. `snippet_hash` をキーに `{status, triaged_at, triaged_by, note}` を辞書化
3. 新 findings に対して既存トリアージを書き戻し、無いものは `未対応` で初期化
4. ステータスに従ってセクション振り分け:

| 条件 | 出力先 |
|---|---|
| `fp_verdict == "likely_false_positive"` **かつ** `status != "対応する"` | `## 偽陽性候補` |
| `status ∈ { "問題なし", "保留" }` | `## トリアージ済み (抑止)` |
| それ以外 (`未対応`, `対応する`) | `## 検出結果` (通常) |

> 「対応する」と既に判定済みのものは FP 判定より優先 (ユーザー意思を尊重)

サマリ件数は `## 検出結果` セクションに出るものだけを Critical/High/Medium/Low/Info で計上する。
`## 偽陽性候補` `## トリアージ済み (抑止)` は参考件数として別表で示す。

---

## Step 7: 出力生成

`lib/output_formatter.md` と `templates/report.md.tmpl` の仕様は `scripts/render_report.py` に実装済み。メインは以下を Bash で実行する:

**`--output` が省略されている場合**: 以下の Bash で日付・連番付きのファイル名を決定してから `render_report.py` を実行する:

```bash
DATE=$(date +%Y-%m-%d)
mkdir -p ./security-reports
NN=01
while [ -f "./security-reports/ipa-security-report-${DATE}-${NN}.md" ]; do
  NN=$(printf "%02d" $((10#$NN + 1)))
done
MD_OUT="./security-reports/ipa-security-report-${DATE}-${NN}.md"
SARIF_OUT="./security-reports/ipa-security-report-${DATE}-${NN}.sarif"

python3 .claude/skills/ipa-security-check/scripts/render_report.py \
    .tmp/ipa-security-check/findings_with_hash.json \
    .tmp/ipa-security-check/verdicts.json \
    "$MD_OUT" \
    "$SARIF_OUT" \
    --scope-summary "<scope の人間可読要約>" \
    --files-scanned <N>
```

**`--output` が指定されている場合**: 指定された値を第 3・第 4 引数として使う。

このスクリプトが行う処理:
1. verdict を `snippet_hash` で findings にマージ (Step 5.4 相当)
2. 出力先 Markdown が存在すれば triage を引き継ぎ (Step 6 相当)
3. 3 セクション振り分け / サマリ集計 / `templates/report.md.tmpl` 置換 / SARIF 生成

最後にユーザーへ要約を 1〜2 文で報告する (件数とファイル名)。

---

## エラーハンドリング

- シャードが空 (対象ファイル 0 件) のカテゴリは起動しない
- シャードがエラーを返したら `errors[]` に記録し、他のシャードの結果は採用する
- 全シャード失敗時のみコマンド失敗とする

---

## 進捗報告

各フェーズの開始時にユーザーへ 1 行報告する。

```
Phase 1 (Critical): 5 shards 起動中…
Phase 1 完了: 12 件検出
Phase 2 (High): 8 shards 起動中…
...
Phase 5 (偽陽性レビュー): 3 shards 起動中… 46 件中 4 件を偽陽性候補と判定
Phase 6 (トリアージ状態マージ): 既存 18 件中 5 件のステータスを引き継ぎ
```
