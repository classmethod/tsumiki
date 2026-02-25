#!/bin/bash
# docker-auto-wrapper.sh
# Claude CodeのPreToolUseフック：ほぼすべてのBashコマンドをDockerコンテナ内で自動実行

set -e

# ログディレクトリの作成
LOG_DIR="/tmp/claude"
mkdir -p "$LOG_DIR" 2>/dev/null || true

# デバッグログ用環境変数（DOCKER_HOOK_DEBUG=1 で有効化）
debug_log() {
  local msg="$*"
  if [[ "${DOCKER_HOOK_DEBUG:-0}" == "1" ]]; then
    echo "[DEBUG] $msg" >&2
    # デバッグモード時のみファイルにも出力
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$LOG_DIR/hook-debug.log" 2>/dev/null || true
  fi
}

# 標準入力からJSONを読み取る
INPUT=$(cat)
debug_log "Input received"

# デバッグモード時のみ実際の入力を保存
if [[ "${DOCKER_HOOK_DEBUG:-0}" == "1" ]]; then
  echo "$INPUT" > "$LOG_DIR/hook-input-last.json" 2>/dev/null || true
fi

# コマンドを抽出
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if [[ $? -ne 0 ]]; then
  debug_log "ERROR: Failed to parse JSON with jq"
  exit 0
fi
debug_log "Command: $COMMAND"

# コマンドが空の場合はそのまま実行
if [ -z "$COMMAND" ]; then
  debug_log "Empty command, skipping"
  exit 0
fi

# コマンドの最初の単語を抽出（複数のパターンに対応）
# パイプ、リダイレクト、コマンド置換を考慮して抽出
# 重要: 複数行コマンドの場合は最初の行の最初の単語のみを取得
CMD_NAME=$(echo "$COMMAND" | head -1 | sed 's/|.*//' | sed 's/>.*//' | sed 's/<.*//' | sed 's/;.*//' | sed 's/&&.*//' | awk '{print $1}' | tr -d ' \t')

# パス情報を削除（例: "/usr/local/bin/go" → "go"）
CMD_BASE=$(basename "$CMD_NAME" 2>/dev/null || echo "$CMD_NAME")
debug_log "CMD_NAME after extraction: [$CMD_NAME]"
debug_log "CMD_BASE after basename: [$CMD_BASE]"
debug_log "Extracted command base: $CMD_BASE"

# 最優先: Git/Docker関連コマンドは必ずホストで実行
# Sandbox無効時でも確実に除外するため、最初にチェック
CRITICAL_HOST_COMMANDS=("git" "docker" "docker-compose")
debug_log "Checking CRITICAL_HOST_COMMANDS for: [$CMD_BASE]"
for critical_cmd in "${CRITICAL_HOST_COMMANDS[@]}"; do
  debug_log "  Comparing: [$CMD_BASE] == [$critical_cmd]"
  if [[ "$CMD_BASE" == "$critical_cmd" ]]; then
    debug_log "  MATCH! Critical host command detected: $CMD_BASE - running on host"
    exit 0
  fi
done
debug_log "No critical command match found"

# ホストで実行すべきコマンドのホワイトリスト
# これらのコマンドはDockerコンテナ内で実行しても意味がない、または実行できない
HOST_ONLY_COMMANDS=(
  "cd"           # シェル組み込みコマンド
  "pushd"        # シェル組み込みコマンド
  "popd"         # シェル組み込みコマンド
  "export"       # 環境変数設定
  "source"       # スクリプト読み込み
  "."            # source のエイリアス
  "alias"        # エイリアス定義
  "unalias"      # エイリアス解除
  "hash"         # コマンドハッシュテーブル
  "type"         # コマンドタイプ確認
  "which"        # コマンドパス確認（場合により）
  "date"         # 日時取得（ホストの日時を使用）
)

# ホワイトリストに含まれているかチェック
for host_cmd in "${HOST_ONLY_COMMANDS[@]}"; do
  if [[ "$CMD_BASE" == "$host_cmd" ]]; then
    debug_log "Host-only command detected: $CMD_BASE - running on host"
    exit 0
  fi
done

# それ以外のすべてのコマンドをDockerコンテナ内で実行
debug_log "Wrapping command for Docker execution"

# プロジェクトルートを確定（スクリプトの 2 階層上 = .claude/hooks/ の親の親）
PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
CONTAINER_NAME="go-app"

# コンテナ状態を確認（失敗時は空文字になる）
CONTAINER_STATUS=$(docker inspect --format '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null) || true
debug_log "Container status: [$CONTAINER_STATUS]"

if [[ "$CONTAINER_STATUS" == "running" ]]; then
  # 起動中のコンテナで実行（高速）
  WRAPPED_COMMAND="docker-compose -f \"$COMPOSE_FILE\" exec -T app sh -c $(printf '%q' "$COMMAND")"
  debug_log "using exec (container running)"
else
  # コンテナを自動起動（db の healthcheck 完了まで待機、60 秒タイムアウト）
  docker-compose -f "$COMPOSE_FILE" up -d --wait --wait-timeout 60 app >&2 && UP_OK=true || UP_OK=false

  if [[ "$UP_OK" == "true" ]]; then
    WRAPPED_COMMAND="docker-compose -f \"$COMPOSE_FILE\" exec -T app sh -c $(printf '%q' "$COMMAND")"
    debug_log "using exec (container started)"
  else
    # 起動失敗時は従来の run --rm にフォールバック
    WRAPPED_COMMAND="docker-compose -f \"$COMPOSE_FILE\" run --rm -T app sh -c $(printf '%q' "$COMMAND")"
    debug_log "using run --rm (fallback)"
  fi
fi
debug_log "Wrapped command: $WRAPPED_COMMAND"

# JSONを出力して、コマンドを変更
jq -n \
  --arg cmd "$WRAPPED_COMMAND" \
  '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "updatedInput": {
        "command": $cmd
      },
      "permissionDecisionReason": "Automatically wrapped to run in Docker container"
    }
  }'

debug_log "Hook completed successfully"
exit 0
