#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook — validates tool usage for async Django TDD projects.
# Blocks dangerous commands, direct DB modifications outside migrations,
# sync HTTP libraries, and flags sync_to_async misuse.
#
# VS Code canonical format: returns hookSpecificOutput.permissionDecision

INPUT=$(cat)

# --- Helper: parse JSON field using jq or python3 fallback ---
json_get() {
    local json="$1" expr="$2"
    if command -v jq &> /dev/null; then
        echo "$json" | jq -r "$expr" 2>/dev/null || echo ""
    elif command -v python3 &> /dev/null; then
        echo "$json" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    keys = '''$expr'''.strip()
    # Simple dotted path parser for common cases
    for path in keys.split(' // '):
        path = path.strip().lstrip('.')
        if path == 'empty':
            continue
        obj = d
        found = True
        for k in path.split('.'):
            if isinstance(obj, dict) and k in obj and obj[k] is not None:
                obj = obj[k]
            else:
                found = False
                break
        if found:
            print(obj if isinstance(obj, str) else json.dumps(obj))
            sys.exit(0)
except Exception:
    pass
" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Parse tool name (VS Code uses snake_case fields)
TOOL_NAME=$(json_get "$INPUT" '.tool_name // .toolName // empty')

if [[ -z "$TOOL_NAME" ]]; then
    echo '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
    exit 0
fi

# --- Helper: deny with reason ---
deny() {
    local reason="$1"
    # Escape backslashes first, then quotes for safe JSON output
    reason=$(echo "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')
    echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"${reason}\"}}"
    exit 0
}

# --- Helper: ask (warn) with reason ---
ask() {
    local reason="$1"
    reason=$(echo "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')
    echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"${reason}\"}}"
    exit 0
}

# --- Extract command text for terminal/execute tools ---
COMMAND_TEXT=""
if [[ "$TOOL_NAME" == "execute" || "$TOOL_NAME" == "bash" || "$TOOL_NAME" == "run_in_terminal" ]]; then
    COMMAND_TEXT=$(json_get "$INPUT" '.tool_input.command // .toolInput.command // .tool_input.input // .toolInput.input // empty')
fi

# --- Extract file content for edit tools ---
FILE_CONTENT=""
if [[ "$TOOL_NAME" == "edit" || "$TOOL_NAME" == "create" || "$TOOL_NAME" == "replace_string_in_file" \
   || "$TOOL_NAME" == "create_file" || "$TOOL_NAME" == "insert" ]]; then
    FILE_CONTENT=$(json_get "$INPUT" '.tool_input.content // .toolInput.content // .tool_input.newString // .toolInput.newString // .tool_input.text // .toolInput.text // empty')
fi

LOWER_CMD=$(echo "$COMMAND_TEXT" | tr '[:upper:]' '[:lower:]')
LOWER_CONTENT=$(echo "$FILE_CONTENT" | tr '[:upper:]' '[:lower:]')

# ========================================================================
# 1. Block dangerous system commands
# ========================================================================
DANGEROUS_PATTERNS=(
    "rm -rf /"
    "rm -rf /*"
    "rm -rf ~"
    "rm -rf ."
    "mkfs"
    "dd if=/dev/zero"
    "dd if=/dev/random"
    "chmod -R 777 /"
    "--no-preserve-root"
    "> /dev/sda"
)

if [[ -n "$LOWER_CMD" ]]; then
    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if [[ "$LOWER_CMD" == *"$pattern"* ]]; then
            deny "Destructive command blocked: matched '$pattern'"
        fi
    done
fi

# ========================================================================
# 2. Block dangerous SQL / Django management commands
# ========================================================================
SQL_DANGER_PATTERNS=(
    "drop table"
    "drop database"
    "truncate table"
)

for pattern in "${SQL_DANGER_PATTERNS[@]}"; do
    if [[ "$LOWER_CMD" == *"$pattern"* || "$LOWER_CONTENT" == *"$pattern"* ]]; then
        deny "Dangerous SQL blocked: matched '$pattern'"
    fi
done

# DELETE FROM without WHERE clause
if [[ "$LOWER_CMD" =~ delete[[:space:]]+from && ! "$LOWER_CMD" =~ where ]]; then
    deny "DELETE FROM without WHERE clause is not allowed"
fi
if [[ "$LOWER_CONTENT" =~ delete[[:space:]]+from && ! "$LOWER_CONTENT" =~ where ]]; then
    deny "DELETE FROM without WHERE clause in file content"
fi

# manage.py flush in production context
if [[ "$LOWER_CMD" == *"manage.py flush"* || "$LOWER_CMD" == *"manage.py reset_db"* ]]; then
    deny "manage.py flush/reset_db blocked — use migrations for data changes"
fi

# ========================================================================
# 3. Block direct database modifications outside migrations
# ========================================================================
if [[ -n "$FILE_CONTENT" ]]; then
    FILE_PATH=$(json_get "$INPUT" '.tool_input.filePath // .toolInput.filePath // .tool_input.path // .toolInput.path // empty')

    # Raw SQL in non-migration files
    if [[ "$FILE_PATH" != *"/migrations/"* ]]; then
        if echo "$LOWER_CONTENT" | grep -qE '(cursor[[:space:]]*\.[[:space:]]*execute|connection[[:space:]]*\.[[:space:]]*cursor|raw[[:space:]]*\()'; then
            ask "Direct SQL detected outside migrations — prefer Django ORM or put raw SQL in a migration"
        fi
    fi
fi

# ========================================================================
# 4. Warn on sync_to_async usage
# ========================================================================
if [[ "$LOWER_CONTENT" == *"sync_to_async"* ]]; then
    ask "sync_to_async detected — this should be a last resort in async Django. Prefer native async ORM and async-compatible libraries."
fi

if [[ "$LOWER_CMD" == *"sync_to_async"* ]]; then
    ask "sync_to_async in command — prefer async-native approaches"
fi

# ========================================================================
# 5. Block requests library (should use httpx in async Django)
# ========================================================================
if echo "$LOWER_CONTENT" | grep -qE '(import[[:space:]]+requests|from[[:space:]]+requests[[:space:]]+import)'; then
    deny "Use httpx instead of requests for async Django projects"
fi

if [[ "$LOWER_CMD" == *"pip install requests"* && "$LOWER_CMD" != *"pip install requests-"* ]]; then
    ask "Consider using httpx instead of requests for async Django compatibility"
fi

# ========================================================================
# Default: allow
# ========================================================================
echo '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
