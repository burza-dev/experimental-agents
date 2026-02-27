#!/usr/bin/env bash
set -euo pipefail

# Validate tool usage before execution (preToolUse hook)
# Reads JSON input from stdin with toolName and toolInput
#
# Blocking response format (Copilot CLI):
#   {"blocked": true, "message": "reason"}
#
# Note: VS Code equivalent uses hookSpecificOutput.permissionDecision
# with values "allow" or "deny" plus a message field.

INPUT=$(cat)

# Extract tool name using jq (if available) or basic parsing
if command -v jq &> /dev/null; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')
else
    # Basic fallback parsing
    TOOL_NAME=$(echo "$INPUT" | grep -o '"toolName"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
fi

if [[ -z "$TOOL_NAME" ]]; then
    echo '{"blocked": false, "message": "No tool name provided"}'
    exit 0
fi

# --- Dangerous command patterns to block ---
DANGEROUS_PATTERNS=(
    "rm -rf /"
    "rm -rf /*"
    "rm -rf ~"
    "rm -rf ."
    "rm -rf .."
    "mkfs"
    "mkfs."
    "format c:"
    "dd if=/dev/zero"
    "dd if=/dev/random"
    "> /dev/sda"
    "chmod -R 777 /"
    ":(){ :|:& };:"
    "--recursive --force /"
    "--force --recursive /"
)

# Check if the execute/bash/terminal tool is being used with dangerous commands
check_dangerous_command() {
    local command_text="$1"
    local lower_command
    lower_command=$(echo "$command_text" | tr '[:upper:]' '[:lower:]')

    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if [[ "$lower_command" == *"$pattern"* ]]; then
            echo "$pattern"
            return 0
        fi
    done
    return 1
}

# For execute-type tools, inspect the command argument for dangerous patterns
if [[ "$TOOL_NAME" == "execute" || "$TOOL_NAME" == "bash" || "$TOOL_NAME" == "run_in_terminal" ]]; then
    COMMAND_TEXT=""
    if command -v jq &> /dev/null; then
        COMMAND_TEXT=$(echo "$INPUT" | jq -r '.toolInput.command // .toolInput.input // empty' 2>/dev/null || echo "")
    else
        # Fallback: extract "command" value from JSON using grep/sed
        COMMAND_TEXT=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"command"[[:space:]]*:[[:space:]]*"//; s/"$//' || echo "")
    fi

    if [[ -n "$COMMAND_TEXT" ]]; then
        if MATCHED=$(check_dangerous_command "$COMMAND_TEXT"); then
            if command -v jq &> /dev/null; then
                jq -nc --arg msg "Destructive command blocked by policy: matched pattern '$MATCHED'" \
                    '{"blocked": true, "message": $msg}'
            else
                echo "{\"blocked\": true, \"message\": \"Destructive command blocked by policy\"}"
            fi
            exit 0
        fi
    fi
fi

# Allow all other operations
if command -v jq &> /dev/null; then
    jq -nc --arg tool "$TOOL_NAME" '{"blocked": false, "tool": $tool}'
else
    SAFE_TOOL=$(printf '%s' "$TOOL_NAME" | sed 's/[\"]/\\&/g; s/[[:cntrl:]]//g')
    echo "{\"blocked\": false, \"tool\": \"${SAFE_TOOL}\"}"
fi
