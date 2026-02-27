#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook — logs tool usage for audit trail.
# Records tool name, timestamp, and result status.
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
    v = d.get('$key1', d.get('$key2', ''))
    print(v if v is not None else '')
except Exception:
    pass
" 2>/dev/null)
    fi
    echo "${val:-$default}"
}

TOOL_NAME=$(json_val "$INPUT" "tool_name" "toolName")
SUCCESS=$(json_val "$INPUT" "success" "success")

LOG_ENTRY="[${TIMESTAMP}] TOOL_USE tool=${TOOL_NAME} success=${SUCCESS}"
echo "$LOG_ENTRY" >> "${LOG_DIR}/tool-usage.log"

echo '{"status":"ok"}'
