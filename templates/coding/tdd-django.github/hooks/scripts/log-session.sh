#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook — logs session start with timestamp and project context.
# VS Code canonical format (snake_case input fields).

INPUT=$(cat)

LOG_DIR="${AGENT_LOG_DIR:-./logs}"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- Helper: extract JSON field ---
json_val() {
    local json="$1" key1="$2" key2="$3" default="${4:-unknown}"
    local val=""
    if command -v jq &> /dev/null; then
        val=$(echo "$json" | jq -r ".$key1 // .$key2 // empty" 2>/dev/null)
    elif command -v python3 &> /dev/null; then
        val=$(echo "$json" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('$key1', d.get('$key2', '')))
except Exception:
    pass
" 2>/dev/null)
    fi
    echo "${val:-$default}"
}

SESSION_ID=$(json_val "$INPUT" "session_id" "sessionId")
WORKSPACE=$(json_val "$INPUT" "workspace_root" "workspaceRoot")

LOG_ENTRY="[${TIMESTAMP}] SESSION_START session=${SESSION_ID} workspace=${WORKSPACE}"
echo "$LOG_ENTRY" >> "${LOG_DIR}/agent-sessions.log"

echo '{"status":"ok"}'
