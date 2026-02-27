---
applyTo: "**/hooks.json,**/hooks/*.json"
---

# Hooks Configuration Rules

The hooks system supports **two formats**. VS Code uses the canonical format; the
Copilot CLI format is kept for backward compatibility. VS Code auto-converts CLI
format to canonical when it loads a `hooks.json` file.

## VS Code Canonical Format (Primary)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "./scripts/on-start.sh",
        "windows": { "command": "powershell -File ./scripts/on-start.ps1" },
        "timeout": 30
      }
    ],
    "PreToolUse": []
  }
}
```

- No `version` property
- Uses PascalCase trigger names
- Uses `command` property (not `bash`/`powershell`)
- OS-specific overrides via `windows`, `linux`, `osx` properties
- Uses `timeout` (not `timeoutSec`)

## Copilot CLI Format (Backward-Compatible)

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [],
    "preToolUse": [],
    "postToolUse": []
  }
}
```

- Requires `version: 1`
- Uses camelCase trigger names
- Uses `bash`/`powershell` properties
- Uses `timeoutSec`

**Note**: Hook configuration files should be named `hooks.json`. Other JSON files
in the hooks directory (like data files or configs) are also valid, but only
`hooks.json` is processed by the agent system.

## Valid Triggers

### VS Code Canonical Triggers (PascalCase)

| Trigger | Description |
|---------|-------------|
| `SessionStart` | When agent session begins |
| `Stop` | When agent session ends |
| `UserPromptSubmit` | After user submits prompt |
| `PreToolUse` | Before tool execution |
| `PostToolUse` | After tool execution |
| `PreCompact` | Before context compaction |
| `SubagentStart` | When a subagent is invoked |
| `SubagentStop` | When a subagent completes |

### Copilot CLI Triggers (camelCase)

| Trigger | Maps to VS Code | Description |
|---------|-----------------|-------------|
| `sessionStart` | `SessionStart` | When agent session begins |
| `sessionEnd` | `Stop` | When agent session ends |
| `userPromptSubmitted` | `UserPromptSubmit` | After user submits prompt |
| `preToolUse` | `PreToolUse` | Before tool execution |
| `postToolUse` | `PostToolUse` | After tool execution |
| `errorOccurred` | *(no equivalent)* | When error occurs (CLI only) |

> **Note**: `sessionEnd` maps to `Stop` in VS Code. `errorOccurred` has no VS Code
> equivalent. `PreCompact`, `SubagentStart`, and `SubagentStop` have no CLI equivalents.

## Trigger Data

Each trigger receives context data via stdin as JSON. Field naming differs by format.

### VS Code Canonical (snake_case fields)

| Trigger | Data Passed |
|---------|-------------|
| `SessionStart` | `{"session_id": "...", "timestamp": "...", "workspace_root": "..."}` |
| `Stop` | `{"session_id": "...", "duration": 123, "tools_used": [...], "summary": "..."}` |
| `UserPromptSubmit` | `{"prompt": "...", "session_id": "...", "timestamp": "..."}` |
| `PreToolUse` | `{"tool_name": "...", "tool_input": {...}, "session_id": "..."}` |
| `PostToolUse` | `{"tool_name": "...", "tool_input": {...}, "tool_response": {...}, "success": true}` |

### Copilot CLI (camelCase fields)

| Trigger | Data Passed |
|---------|-------------|
| `sessionStart` | `{"sessionId": "...", "timestamp": "...", "workspaceRoot": "..."}` |
| `sessionEnd` | `{"sessionId": "...", "duration": 123, "toolsUsed": [...], "summary": "..."}` |
| `userPromptSubmitted` | `{"prompt": "...", "sessionId": "...", "timestamp": "..."}` |
| `preToolUse` | `{"toolName": "...", "toolInput": {...}, "sessionId": "..."}` |
| `postToolUse` | `{"toolName": "...", "toolInput": {...}, "toolOutput": {...}, "success": true}` |
| `errorOccurred` | `{"error": "...", "stack": "...", "context": {...}}` |

## Blocking Response from PreToolUse

The `PreToolUse` / `preToolUse` hook can block tool execution. The response
format differs between the two systems.

### VS Code Canonical Format

Return `hookSpecificOutput` with a `permissionDecision`:

```bash
#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

if [[ "$TOOL_NAME" == "execute" ]]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
  if [[ "$COMMAND" == *"rm -rf"* ]]; then
    echo '{"hookSpecificOutput": {"permissionDecision": "deny", "permissionDecisionReason": "Destructive command blocked by policy"}}'
    exit 0
  fi
fi

echo '{"hookSpecificOutput": {"permissionDecision": "allow"}}'
```

Valid `permissionDecision` values: `"allow"`, `"deny"`, `"ask"`.

### Copilot CLI Format

Return `blocked` with an optional `message`:

```bash
#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')

if [[ "$TOOL_NAME" == "execute" ]]; then
  COMMAND=$(echo "$INPUT" | jq -r '.toolInput.command // empty')
  if [[ "$COMMAND" == *"rm -rf"* ]]; then
    echo '{"blocked": true, "message": "Destructive command blocked by policy"}'
    exit 0
  fi
fi

echo '{"blocked": false}'
```

## Hook Entry Structure

### VS Code Canonical (Primary)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "type": "command",
        "command": "./scripts/validate-tool.sh",
        "windows": { "command": "powershell -File ./scripts/validate-tool.ps1" },
        "timeout": 30
      }
    ]
  }
}
```

#### Required Properties
- `type` - Must be `"command"`
- `command` - Command to execute

#### Optional Properties
- `windows` - Windows-specific override (`{ "command": "..." }`)
- `linux` - Linux-specific override (`{ "command": "..." }`)
- `osx` - macOS-specific override (`{ "command": "..." }`)
- `timeout` - Timeout in seconds (default: 30)
- `cwd` - Working directory (default: repo root)
- `env` - Environment variables

### Copilot CLI (Backward-Compatible)

```json
{
  "type": "command",
  "bash": "./scripts/hook.sh",
  "powershell": "./scripts/hook.ps1",
  "cwd": ".",
  "timeoutSec": 30,
  "env": {
    "KEY": "value"
  }
}
```

#### Required Properties
- `type` - Must be `"command"`
- `bash` or `powershell` - At least one required

#### Optional Properties
- `cwd` - Working directory (default: repo root)
- `timeoutSec` - Timeout in seconds (default: 30)
- `env` - Environment variables

## Script Requirements

Referenced scripts MUST:
- Exist at the specified path
- Be executable (`chmod +x`)
- Have proper shebang (`#!/usr/bin/env bash`)
- Handle JSON input from stdin
- Output valid JSON (if applicable)

### Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
# VS Code canonical uses snake_case; CLI uses camelCase
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // .toolName // empty')

# Hook logic here

echo '{"status": "success"}'
```

## Cross-Platform

### VS Code Canonical

Use OS-specific properties:

```json
{
  "type": "command",
  "command": "./scripts/hook.sh",
  "windows": { "command": "powershell -File ./scripts/hook.ps1" }
}
```

### Copilot CLI

Provide both `bash` and `powershell`:

```json
{
  "type": "command",
  "bash": "echo 'Unix'",
  "powershell": "Write-Host 'Windows'"
}
```

## Directory Structure

```
.github/
├── hooks/
│   ├── hooks.json        # Configuration
│   └── scripts/          # Hook scripts
│       ├── on-start.sh
│       └── validate.sh
```

## Forbidden Patterns

- Invalid trigger names
- Missing `type: "command"`
- Scripts that don't exist
- Very long timeouts (> 300 seconds)
- Security vulnerabilities in scripts
- Missing `version: 1` (in Copilot CLI format)

## Quality Standards

- Valid JSON syntax
- Reasonable timeouts
- Error handling in scripts
- Cross-platform compatibility
- No hardcoded credentials
- File content must be under 30,000 characters
