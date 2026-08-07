# 抽出サブエージェント プロンプトテンプレート

Phase 3 で親が Agent tool（general-purpose、model は既定 sonnet）に渡すプロンプトの定型。`{...}` を実値に置換する。**親は項目本文を受け取らない。サブエージェントは出力ファイルに直接書き、メタデータ要約のみ返す。**

## A. 機能グループ担当（L2 抽出 + L1 候補）

```
あなたは UAT・受入試験項目の抽出担当です。機能グループ「{group}」を担当します。

## 読んでよいもの（読込予算: 合計 {budget:-10000} 行まで）
- 仕様: {spec_paths}
- E2E spec: {e2e_paths}
- 単体テスト: {unit_paths}（カバレッジ判定用。describe/test/@Test 名の grep のみ、アサーション本文の精読は不要）
- 画面: {page_paths}（ファイル名と主要コンポーネントの把握のみ、実装の精読は不要）
- 粒度基準: {skill_dir}/references/test-levels.md（必読。特に §7 カバレッジ判定）
- 出力仕様: {skill_dir}/references/output-format.md（必読）
- 逆引き専用（原則読まない。特定機能のエッジケース補完が必要な場合のみ、ファイル名 grep で該当上位2件まで）: {lookup_only_paths}

## 環境前提（前提条件欄に反映すること）
{env_summary}

## やること
1. 担当範囲の仕様・E2E spec を読み、L2 項目（1機能×1観点=1項目、観点: 正常/異常/境界/権限）を抽出する。
   test-levels.md §3 の「特に厚くする領域」に該当する機能は観点を厚めに取る。
2. 自動化トレース: 担当 E2E spec に対し `grep -hoE '{tc_pattern}.*'` で ID と同一行の説明文を収集し、
   各 L2 項目に対応 ID を紐づける（多対多可。対応がなければ「手動のみ」）。
3. カバレッジ判定: test-levels.md §7 に従い、各 L2 項目に判定値（E2E / Unit / E2E+Unit / なし）を付ける。
   E2E は手順 2 の結果、Unit は担当単体テストの describe/test/@Test 名 grep で名前ベース判定する
   （自信がなければ「なし」に倒す）。§7 の分離条件（E2E カバー済み・厚くする領域非該当・
   本番相当環境価値なし・Validation 不要のすべて）を満たす項目は区分「自動カバー済み」とする。
   **カバレッジが「Unit」のみ・「なし」の項目は分離してはならない。迷ったら UAT 対象に残す。**
4. 要件トレース: {requirements_ref} に担当範囲の要件があれば紐づける。なければ「REQ なし」。
5. ID は {id_range} の範囲内で採番する（範囲外は使用禁止。区分を跨いで通し採番でよい）。
6. 項目本文を書く: UAT 対象は {output_file}、自動カバー済みは {covered_file} に
   output-format.md §3 の型で直接書く（covered には分離理由行と冒頭注記を付ける。
   分離該当が 0 件なら {covered_file} は作らない）。
7. L1 候補: 担当グループが起点となる業務シナリオを test-levels.md §2 の 5 観点で洗い出し、
   本文は書かず 1 行サマリのみ挙げる（L1 の本文化は別担当が行う）。

## 禁止事項
- {output_file} / {covered_file} 以外への書き込み
- 読込予算の超過（超えそうなら仕様の index/見出しのみで判断し、その旨を要約で報告）
- 期待結果の創作（仕様・spec から根拠が取れないものは「要確認」と明記）

## 最後に、以下の YAML のみを応答として返す（項目本文は返さない）
group: {group}
items: { L2: <UAT対象件数>, L2_covered: <自動カバー済み分離件数> }
id_range_used: <実際に使った範囲>
files_written: [<ファイル名>]
l1_candidates:
  - "<業務の言葉での1行サマリ（登場ロールと画面を含む）>"
trace_stats: { tc_linked: <件数>, manual_only: <件数> }
coverage_stats: { e2e: <E2E件数>, unit: <Unit件数>, both: <E2E+Unit件数>, none: <なし件数> }
requirements_linked: <件数>
sources_missing: ["<担当範囲で見つからなかった仕様>"]
low_priority_lookups: ["<逆引きしたファイルと理由>"]
budget_note: "<予算内に収まったか。収まらなかった場合の割り切り>"
```

## B. L1 統合担当（1 体）

```
あなたは UAT の L1 業務シナリオの統合担当です。

## 入力
- 各グループ担当が挙げた L1 候補（1行サマリ）: {l1_candidates_all}
- 粒度基準: {skill_dir}/references/test-levels.md §2, §5（必読）
- 出力仕様: {skill_dir}/references/output-format.md（必読）
- 環境前提: {env_summary}
- 必要に応じて読んでよい仕様（予算 8000 行）: {spec_index_paths}

## やること
1. 候補を統合する: 同一業務の重複をまとめ、複数グループをまたぐ End-to-End シナリオに再構成する。
   test-levels.md §2 の 5 観点（主業務/後続/セットアップ/データ活用/制限・例外)の網羅を確認し、
   欠けている観点は仕様 index から補完する。
2. 各シナリオを UAT-L1-nnn で採番し、{output_file} に output-format.md §3 の型で直接書く。
   L1 は業務担当者が読める言葉のみ。内部用語（BFF・API 名・内部設定キー）は使用禁止。
3. 手順は 5〜15 ステップ。件数目安: {l1_target_range}（test-levels.md §6）。

## 最後に YAML のみ返す
items: { L1: <件数> }
observation_coverage: { 主業務: n, 後続: n, セットアップ: n, データ活用: n, 制限例外: n }
dropped_duplicates: <統合した候補数>
```

## C. L3 非機能・運用担当（1 体）

```
あなたは L3（非機能・運用受入）の抽出担当です。

## 読んでよいもの（予算 8000 行）
- セキュリティ資料: {security_paths}
- 非機能試験の実績: {loadtest_paths}
- 運用・監視資料: {ops_paths}
- 粒度基準: {skill_dir}/references/test-levels.md §4, §5 / 出力仕様: output-format.md（必読）

## やること
1. 「プロジェクトに存在する非機能活動の結果を受入判定に紐づける」方針で L3 項目
   （1確認活動=1項目、実績資料への参照＋判定基準）を抽出し、{output_file} に直接書く。
2. 想定される確認活動（性能/セキュリティ/バッチ稼働/監視発報/バックアップリストア/手順書実地）のうち
   **該当資料が存在しないものは項目化せず {gaps_file} に記録する**（output-format.md §5 の表形式）。
3. ID は UAT-L3-nnn。

## 最後に YAML のみ返す
items: { L3: <件数> }
gaps: <gaps.md に書いた件数>
files_written: [...]
```
