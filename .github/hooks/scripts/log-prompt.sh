#!/usr/bin/env bash
set -euo pipefail

# Log user prompts for analytics and debugging
# Reads JSON input with prompt text

LOG_DIR="${LOG_DIR:-./logs}"
LOG_FILE="${LOG_DIR}/prompts.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

INPUT=$(cat)

# Get timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Extract prompt (truncate to prevent huge logs)
if command -v jq &> /dev/null; then
    PROMPT=$(echo "$INPUT" | jq -r '.prompt // "no-prompt"' | head -c 500)
    SESSION_ID=$(echo "$INPUT" | jq -r '.sessionId // "unknown"')
else
    PROMPT="<jq-required>"
    SESSION_ID="unknown"
fi

# Sanitize for logging
PROMPT="${PROMPT//[$'\n\r']/ }"

# Write log entry
{
    if command -v jq &> /dev/null; then
        jq -nc \
            --arg ts "$TIMESTAMP" \
            --arg session "$SESSION_ID" \
            --arg prompt "$PROMPT" \
            '{"timestamp": $ts, "event": "userPrompt", "sessionId": $session, "prompt": $prompt}'
    else
        echo "{\"timestamp\": \"${TIMESTAMP}\", \"event\": \"userPrompt\"}"
    fi
} >> "$LOG_FILE"

echo '{"status": "logged"}'
