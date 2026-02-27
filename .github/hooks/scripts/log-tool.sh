#!/usr/bin/env bash
set -euo pipefail

# Log tool execution results for auditing
# Reads JSON input from stdin with toolName, toolArgs, and result

LOG_DIR="${LOG_DIR:-./logs}"
LOG_FILE="${LOG_DIR}/tool-usage.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Read input from stdin
INPUT=$(cat)

# Get timestamp in ISO 8601 format
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Extract fields using jq (if available) or basic parsing
if command -v jq &> /dev/null; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // "unknown"')
    TOOL_ARGS=$(echo "$INPUT" | jq -c '.toolInput // .toolArgs // {}')
    # Truncate result to avoid huge log entries
    RESULT_SUMMARY=$(echo "$INPUT" | jq -r '.toolOutput // .result // .toolResult // "no-result"' | head -c 200)
else
    # Basic fallback parsing
    TOOL_NAME=$(echo "$INPUT" | grep -o '"toolName"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 || echo "unknown")
    TOOL_ARGS="<parsing-unavailable>"
    RESULT_SUMMARY="<jq-required-for-result>"
fi

# Sanitize values for logging (remove newlines, limit length)
TOOL_NAME="${TOOL_NAME//[$'\n\r']/ }"
RESULT_SUMMARY="${RESULT_SUMMARY//[$'\n\r']/ }"
RESULT_SUMMARY="${RESULT_SUMMARY:0:200}"

# Write log entry
{
    if command -v jq &> /dev/null; then
        jq -nc \
            --arg ts "$TIMESTAMP" \
            --arg tool "$TOOL_NAME" \
            --argjson args "$TOOL_ARGS" \
            --arg result "$RESULT_SUMMARY" \
            '{"timestamp": $ts, "event": "postToolUse", "tool": $tool, "args": $args, "result": $result}'
    else
        # Escape special characters for JSON safety
        SAFE_TOOL=$(printf '%s' "$TOOL_NAME" | sed 's/[\"]/\\&/g; s/[[:cntrl:]]//g')
        SAFE_RESULT=$(printf '%s' "$RESULT_SUMMARY" | sed 's/[\"]/\\&/g; s/[[:cntrl:]]//g')
        echo "{\"timestamp\": \"${TIMESTAMP}\", \"event\": \"postToolUse\", \"tool\": \"${SAFE_TOOL}\", \"result\": \"${SAFE_RESULT}\"}"
    fi
} >> "$LOG_FILE"

# Output success response
echo '{"status": "continue"}'
