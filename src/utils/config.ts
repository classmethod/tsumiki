import * as path from "node:path";
import fs from "fs-extra";

export type Config = {
  target?: string;
};

/**
 * 設定ファイルから設定を読み込みます。
 * @returns 設定オブジェクト。ファイルが存在しない場合は空のオブジェクトを返します。
 */
export async function loadConfig(): Promise<Config> {
  const configPath = path.join(process.cwd(), ".tsumikirc");
  if (await fs.pathExists(configPath)) {
    try {
      // .tsumikirc は TOML 形式と仮定
      const configFileContent = await fs.readFile(configPath, "utf-8");
      // シンプルなパーサー: `key = value` 形式のみ対応
      const config: Config = {};
      configFileContent.split("\n").forEach((line) => {
        const [key, value] = line.split("=").map((part) => part.trim());
        if (key && value) {
          // Remove quotes from value if present
          config[key as keyof Config] = value.replace(/^["']|["']$/g, "");
        }
      });
      return config;
    } catch (err) {
      console.error("Warning: Could not read .tsumikirc file:", err);
      return {};
    }
  }
  return {};
}
