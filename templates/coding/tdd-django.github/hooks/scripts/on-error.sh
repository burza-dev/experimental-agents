#!/usr/bin/env bash
set -euo pipefail

# Error hook — logs error details and suggests recovery actions
# for common Django errors (migration conflicts, import errors, test failures).
#
# Note: errorOccurred has no VS Code canonical equivalent, but this script
# handles both formats for portability.

INPUT=$(cat)

LOG_DIR="${AGENT_LOG_DIR:-./logs}"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

ERROR_MSG=""
ERROR_STACK=""
if command -v jq &> /dev/null; then
    ERROR_MSG=$(echo "$INPUT" | jq -r '.error // .message // "unknown error"')
    ERROR_STACK=$(echo "$INPUT" | jq -r '.stack // ""')
elif command -v python3 &> /dev/null; then
    ERROR_MSG=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('error', d.get('message', 'unknown error')))
except Exception:
    print('unknown error')
" 2>/dev/null)
    ERROR_STACK=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('stack', ''))
except Exception:
    pass
" 2>/dev/null)
else
    ERROR_MSG=$(echo "$INPUT" | grep -oE '"error"[[:space:]]*:[[:space:]]*"[^"]+' | sed 's/^"error"[[:space:]]*:[[:space:]]*"//') || ERROR_MSG="unknown error"
    ERROR_STACK=""
fi

# Log the error
LOG_ENTRY="[${TIMESTAMP}] ERROR: ${ERROR_MSG}"
echo "$LOG_ENTRY" >> "${LOG_DIR}/errors.log"
if [[ -n "$ERROR_STACK" ]]; then
    echo "  STACK: ${ERROR_STACK}" >> "${LOG_DIR}/errors.log"
fi

# Suggest recovery actions for common Django errors
LOWER_ERROR=$(echo "$ERROR_MSG $ERROR_STACK" | tr '[:upper:]' '[:lower:]')
SUGGESTION=""

if [[ "$LOWER_ERROR" == *"conflicting migrations"* || "$LOWER_ERROR" == *"inconsistentmigrationhistory"* ]]; then
    SUGGESTION="Migration conflict detected. Try: python manage.py makemigrations --merge"
elif [[ "$LOWER_ERROR" == *"no such table"* || "$LOWER_ERROR" == *"relation"*"does not exist"* ]]; then
    SUGGESTION="Missing table. Run: python manage.py migrate"
elif [[ "$LOWER_ERROR" == *"importerror"* || "$LOWER_ERROR" == *"modulenotfounderror"* ]]; then
    SUGGESTION="Import error. Check: 1) Package installed in venv 2) PYTHONPATH correct 3) __init__.py exists"
elif [[ "$LOWER_ERROR" == *"assert"*"failed"* || "$LOWER_ERROR" == *"test"*"failed"* ]]; then
    SUGGESTION="Test failure. Run the failing test in isolation: pytest <test_file>::<test_name> -vvs"
elif [[ "$LOWER_ERROR" == *"operationalerror"* && "$LOWER_ERROR" == *"database"* ]]; then
    SUGGESTION="Database connection error. Check: 1) DB service running 2) DATABASE_URL correct 3) Credentials valid"
elif [[ "$LOWER_ERROR" == *"synchronousonlyoperation"* ]]; then
    SUGGESTION="Sync operation in async context. Use async ORM methods or wrap with sync_to_async as last resort."
elif [[ "$LOWER_ERROR" == *"permission"*"denied"* ]]; then
    SUGGESTION="Permission denied. Check file/directory permissions and user privileges."
elif [[ "$LOWER_ERROR" == *"address already in use"* ]]; then
    SUGGESTION="Port in use. Find process: lsof -i :<port> | kill it, or use a different port."
fi

# Build response using python3 for safe JSON encoding
if command -v python3 &> /dev/null; then
    python3 -c "
import json, sys
resp = {'status': 'logged', 'error': sys.argv[1]}
if sys.argv[2]:
    resp['suggestion'] = sys.argv[2]
print(json.dumps(resp))
" "$ERROR_MSG" "$SUGGESTION"
elif command -v jq &> /dev/null; then
    if [[ -n "$SUGGESTION" ]]; then
        jq -nc --arg err "$ERROR_MSG" --arg sug "$SUGGESTION" \
            '{"status":"logged","error":$err,"suggestion":$sug}'
    else
        jq -nc --arg err "$ERROR_MSG" \
            '{"status":"logged","error":$err}'
    fi
else
    if [[ -n "$SUGGESTION" ]]; then
        ESCAPED_SUGGESTION=$(echo "$SUGGESTION" | sed 's/\\/\\\\/g; s/"/\\"/g')
        echo "{\"status\":\"logged\",\"suggestion\":\"${ESCAPED_SUGGESTION}\"}"
    else
        echo '{"status":"logged"}'
    fi
fi
