# TDD Greenフェーズ（最小限の実装）

TDDのGreenフェーズを実行します。

## 事前確認
まず、TDDメモファイル `doc/implementation/{test_case_name}-memo.md` を確認してください：
- **Redフェーズの内容確認**: 作成されたテストケース、期待される失敗、実装要求事項を把握
- **関連ファイル確認**: メモファイル内の関連ファイル情報を参照し、要件定義やテストケース定義を確認
- **テストコードの確認**: 実装すべき関数・メソッドの仕様を理解
- **実装方針の検討**: Redフェーズで特定された要求事項に基づいて最小実装を計画

### 検証結果の参照
メモファイル内に「完全性検証結果」セクションがある場合は、以下を参考に実装を進めてください：
- **検証判定**: 過去の検証結果（合格/不合格）を参考にして、実装の品質目標を設定
- **実装率**: 過去の実装進捗状況を把握し、現在の実装がどの位置にあるかを確認
- **テスト成功率**: 以前のテスト成功率を参考にして、実装品質を判断
- **未実装テストケース**: 過去に特定された未実装テストケースを参考にして、実装範囲を決定
- **備考**: 前回の検証で記録された課題や注意事項を実装時に考慮

## 信頼性レベル指示

実装コード作成時には、各実装内容について元の資料との照合状況を以下の信号でコメントしてください：

- 🟢 **青信号**: 元の資料を参考にしてほぼ推測していない場合
- 🟡 **黄信号**: 元の資料から妥当な推測の場合
- 🔴 **赤信号**: 元の資料にない推測の場合

## 目標
Redフェーズで作成したテストを通すための**最小限の実装**を行ってください。

## 実装の原則
- **テストが確実に通ること最優先**
- コードの美しさは二の次（次のRefactorフェーズで改善）
- 「とりあえず動く」レベルでOK
- ハードコーディングでも構わない
- 複雑なロジックは後回し、シンプルな実装を心がける

## 実装時の日本語コメント要件
実装コードには以下の日本語コメントを必ず含めてください：

### 関数・メソッドレベルのコメント
```javascript
/**
 * 【機能概要】: [この関数が何をするかを日本語で説明]
 * 【実装方針】: [なぜこのような実装方法を選んだかを説明]
 * 【テスト対応】: [どのテストケースを通すための実装かを明記]
 * 🟢🟡🔴 信頼性レベル: [この実装が元資料のどの程度に基づいているか]
 * @param {type} paramName - [パラメータの説明]
 * @returns {type} - [戻り値の説明]
 */
function {{function_name}}(paramName) {
  // 【実装内容】: [実装している処理の詳細説明]
}
```

### 処理ブロックレベルのコメント
```javascript
function processData(input) {
  // 【入力値検証】: [入力値の妥当性をチェックする理由と方法] 🟢🟡🔴
  if (!input) {
    throw new Error('入力値が不正です'); // 【エラー処理】: [なぜこのエラーが必要かを説明] 🟢🟡🔴
  }
  
  // 【データ処理開始】: [メイン処理の開始を明示] 🟢🟡🔴
  // 【処理方針】: [この処理がテストを通すためにどう貢献するかを説明] 🟢🟡🔴
  const result = {
    // 【結果構造】: [戻り値の構造とその理由を説明]
    validData: [],
    invalidData: [],
    errors: []
  };
  
  // 【結果返却】: [処理結果を返す理由と内容の説明]
  return result;
}
```

### 変数・定数のコメント
```javascript
// 【定数定義】: [この定数が必要な理由と使用目的]
const MAX_FILE_SIZE = 1024 * 1024; // 【制限値】: ファイルサイズの上限（1MB）を設定

// 【変数初期化】: [この変数がテスト通過のためになぜ必要かを説明]
let processedCount = 0; // 【カウンタ】: 処理済みファイル数を追跡するためのカウンタ
```

### エラーハンドリングのコメント
```javascript
try {
  // 【実処理実行】: [実際の処理を実行する部分の説明]
  const data = processFile(filePath);
} catch (error) {
  // 【エラー捕捉】: [エラーが発生した場合の対処方針]
  // 【テスト要件対応】: [テストで期待されるエラーハンドリングを満たすための処理]
  return {
    success: false,
    error: error.message // 【エラー情報】: テストで検証されるエラーメッセージを適切に返却
  };
}
```

## 実装例
```javascript
/**
 * 【機能概要】: JSONファイルパスを検証し、有効/無効なパスを分類する
 * 【実装方針】: テストケースを通すために最低限必要な機能のみを実装
 * 【テスト対応】: tdd-red フェーズで作成されたテストケースを通すための実装
 */
function {{function_name}}(input) {
  // 【入力値検証】: 不正な入力値を早期に検出してエラーを防ぐ
  if (!input) {
    // 【エラー処理】: テストで期待されるエラーケースに対応
    throw new Error('入力値が必要です');
  }
  
  // 【最小限実装】: テストを通すための最もシンプルな実装
  // 【ハードコーディング許可】: リファクタ段階で改善予定のため、現段階では固定値でOK
  return {{simple_return_value}};
}
```

## 段階的実装のガイドライン
1. **まず1つのテストケースだけ通す**
   - 【実装戦略】: 複数テストの同時対応は複雑化を招くため避ける
   - 【品質確保】: 1つずつ確実に実装することで品質を担保
   
2. **最も簡単な方法で実装**
   - 【シンプル実装】: 複雑なアルゴリズムは後のリファクタで追加
   - 【可読性重視】: 現段階では理解しやすさを最優先
   
3. **他のテストケースは後回し**
   - 【段階的開発】: TDDの原則に従い、1ステップずつ進める
   - 【影響範囲限定】: 変更の影響を最小限に抑える
   
4. **エラーハンドリングも最小限**
   - 【必要最小限】: テストで要求される部分のみ実装
   - 【将来拡張可能】: リファクタ段階で詳細なエラー処理を追加予定

## 提供してください
1. **実装コード**: テストを通すコード（必須の日本語コメント付き）
2. **テスト実行結果**: 実際にテストが通ることの確認
3. **実装の説明**: どのような考えで実装したか（日本語コメントとの対応関係）
4. **課題の特定**: 現在の実装の問題点（リファクタ対象の明確化）

実装完了後、以下を実行してください：

1. **メモファイル更新**: doc/implementation/{test_case_name}-memo.mdファイルのGreenフェーズセクションを更新
   - 実装方針、実装コード、テスト結果、課題・改善点を記録
   - 次のRefactorフェーズで参照できるよう詳細に記録
2. 実装コードと設計内容をdoc/implementation/{feature_name}-green-phase.mdに保存（既存ファイルがある場合は追記）
3. TODOステータスを更新（Greenフェーズ完了をマーク）
4. **自動遷移判定**: 以下の条件を満たす場合は自動で `/tdd-refactor` を実行
   - 全てのテストが成功していることを確認済み
   - 実装がシンプルで理解しやすい
   - 明らかなリファクタリング箇所がある
   - 機能的な問題がない
5. **手動確認**: 自動遷移条件を満たさない場合は以下を提供してください：
   - 「テストが通ったことを確認しました。」
   - 「現在の実装: [簡潔な説明]」
   - 「実装に含めた日本語コメント: [コメントの目的と内容]」
   - 「リファクタリングの候補: [改善すべき点]」
   - 「次のRefactorフェーズに進んでよろしいですか？」

## 品質判定基準
```
✅ 高品質:
- テスト結果: 全て成功
- 実装品質: シンプルかつ動作する
- リファクタ箱所: 明確に特定可能
- 機能的問題: なし

⚠️ 要改善:
- テストの一部が失敗
- 実装が複雑すぎる
- リファクタ方針が不明
- 機能に懸念がある
```

## TODO更新パターン
```
- 現在のTODO「Greenフェーズ（最小実装）」を「completed」にマーク
- 最小実装フェーズの完了をTODO内容に反映
- 品質判定結果をTODO内容に記録
- 次のフェーズ「Refactorフェーズ（品質改善）」をTODOに追加
```

次のステップ: `/tdd-refactor` でコードの品質を改善します。