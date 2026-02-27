#!/usr/bin/env bash
set -euo pipefail

# Handle errors during agent execution
# Can be extended to send notifications, create issues, etc.

LOG_DIR="${LOG_DIR:-./logs}"
LOG_FILE="${LOG_DIR}/errors.log"

mkdir -p "$LOG_DIR"

INPUT=$(cat)

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v jq &> /dev/null; then
    ERROR_MSG=$(echo "$INPUT" | jq -r '.error // "unknown-error"' | head -c 1000)
    CONTEXT=$(echo "$INPUT" | jq -r '.context // "no-context"' | head -c 500)
    SESSION_ID=$(echo "$INPUT" | jq -r '.sessionId // "unknown"')
else
    ERROR_MSG="<jq-required>"
    CONTEXT="<jq-required>"
    SESSION_ID="unknown"
fi

# Sanitize
ERROR_MSG="${ERROR_MSG//[$'\n\r']/ }"
CONTEXT="${CONTEXT//[$'\n\r']/ }"

# Log the error
{
    if command -v jq &> /dev/null; then
        jq -nc \
            --arg ts "$TIMESTAMP" \
            --arg session "$SESSION_ID" \
            --arg error "$ERROR_MSG" \
            --arg ctx "$CONTEXT" \
            '{"timestamp": $ts, "event": "error", "sessionId": $session, "error": $error, "context": $ctx}'
    else
        echo "{\"timestamp\": \"${TIMESTAMP}\", \"event\": \"error\"}"
    fi
} >> "$LOG_FILE"

# Return continue to allow agent to handle error normally
echo '{"status": "logged", "continue": true}'
