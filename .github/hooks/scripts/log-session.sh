#!/usr/bin/env bash
set -euo pipefail

# Log session start/end events
# Usage: ./log-session.sh [start|end]

# Read JSON context from stdin and parse sessionId for log correlation
INPUT=$(cat)

SESSION_ID="unknown"
if command -v jq &> /dev/null; then
    SESSION_ID=$(echo "$INPUT" | jq -r '.sessionId // "unknown"' 2>/dev/null || echo "unknown")
else
    # Basic fallback parsing
    SESSION_ID=$(echo "$INPUT" | grep -o '"sessionId"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 || echo "unknown")
fi

ACTION="${1:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_DIR="${LOG_DIR:-./logs}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/session.log"

log_message() {
    local message="$1"
    echo "[${TIMESTAMP}] [session:${SESSION_ID}] ${message}" >> "${LOG_FILE}"
}

case "${ACTION}" in
    start)
        log_message "Session started"
        echo '{"status": "logged", "action": "start"}'
        ;;
    end)
        log_message "Session ended"
        echo '{"status": "logged", "action": "end"}'
        ;;
    *)
        echo '{"status": "error", "message": "Unknown action"}'
        exit 1
        ;;
esac
