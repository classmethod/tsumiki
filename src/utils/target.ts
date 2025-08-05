import * as path from "node:path";
import { type Config, loadConfig } from "./config.js";

/**
 * ターゲットとなるCoder環境を取得します。
 * 優先順位: コマンドラインオプション > 設定ファイル > デフォルト
 * @param cliTarget コマンドラインオプションで指定されたターゲット
 * @returns ターゲットとなるCoder環境 ('claude' or 'qwen')
 */
export async function getTarget(
  cliTarget: string | undefined,
): Promise<string> {
  // 1. コマンドラインオプションが指定されていればそれを使用
  if (cliTarget) {
    return cliTarget;
  }

  // 2. 設定ファイルから読み込み
  const config: Config = await loadConfig();
  if (config.target) {
    return config.target;
  }

  // 3. デフォルトはclaude
  return "claude";
}

/**
 * ターゲットに対応するディレクトリパスを取得します。
 * @param target ターゲット ('claude' or 'qwen' or その他)
 * @returns ディレクトリパス
 */
export function getTargetDir(target: string): string {
  const currentDir = process.cwd();

  switch (target) {
    case "claude":
      return path.join(currentDir, ".claude", "commands");
    case "qwen":
      return path.join(currentDir, ".qwen", "commands");
    default:
      // ここでは、指定された名前をそのままディレクトリ名として使用 (例: '.mycoder/commands')
      // ただし、'..' や '/' などの不正な文字列は避けるべき
      // 簡易的な検証を追加
      if (
        target.includes("..") ||
        target.includes("/") ||
        target.includes("\\")
      ) {
        throw new Error(`Invalid target name: ${target}`);
      }
      return path.join(currentDir, `.${target}`, "commands");
  }
}
