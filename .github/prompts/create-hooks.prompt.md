---
name: create-hooks
description: Create hooks configuration for GitHub Copilot agents
---

# Create Hooks Configuration

Create hooks to extend agent behavior at key execution points.

## Target Project
{{target_project}}

## Hook Requirements
Describe what the hooks should do:
{{hook_requirements}}

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{target_project}}` | Yes | path | Absolute path to the target project directory |
| `{{hook_requirements}}` | Yes | string | Description of what custom behavior the hooks should implement |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## Available Triggers

Trigger names differ between CLI and VS Code environments:

### CLI Triggers
- [ ] `sessionStart` - When agent session begins
- [ ] `sessionEnd` - When agent session ends
- [ ] `userPromptSubmitted` - After user submits prompt
- [ ] `preToolUse` - Before tool execution
- [ ] `postToolUse` - After tool execution
- [ ] `errorOccurred` - When error occurs

### VS Code Triggers
- [ ] `SessionStart` - When agent session begins
- [ ] `Stop` - When agent session ends
- [ ] `UserPromptSubmit` - After user submits prompt
- [ ] `PreToolUse` - Before tool execution
- [ ] `PostToolUse` - After tool execution
- [ ] `PreCompact` - Before context compaction
- [ ] `SubagentStart` - When a subagent starts
- [ ] `SubagentStop` - When a subagent stops

> **Important:** Use the correct trigger names for your target environment. CLI and VS Code have different casing and naming conventions.

## Hook Input JSON Schema

Scripts receive JSON input via stdin. The schema varies by trigger.

> **Format differences:** In CLI, tool hook inputs use `toolName` and `toolArgs` fields; in VS Code, the equivalent fields are `tool_name` and `tool_input`. For blocking tool execution: CLI returns `{"blocked": true}` in output; VS Code uses `hookSpecificOutput.permissionDecision` set to `"deny"`.

### CLI Format

**sessionStart/sessionEnd:**
```json
{
  "sessionId": "string",
  "timestamp": "ISO8601 string"
}
```

**userPromptSubmitted:**
```json
{
  "sessionId": "string",
  "prompt": "string (user's message)",
  "timestamp": "ISO8601 string"
}
```

**preToolUse/postToolUse:**
```json
{
  "sessionId": "string",
  "toolName": "string",
  "toolArgs": { "...tool-specific arguments" },
  "result": "string (postToolUse only)",
  "timestamp": "ISO8601 string"
}
```

**errorOccurred:**
```json
{
  "sessionId": "string",
  "error": "string (error message)",
  "context": "string (where error occurred)",
  "timestamp": "ISO8601 string"
}
```

### VS Code Format Differences

When targeting VS Code, adjust the following fields in hook input/output:
- Use `tool_name` instead of `toolName`
- Use `tool_input` instead of `toolArgs`
- For `preToolUse` blocking: return `{"hookSpecificOutput": {"permissionDecision": "deny"}}` instead of `{"blocked": true}`

## Workflow

1. Identify what custom behavior is needed
2. Select appropriate trigger points
3. Create `hooks.json` configuration
4. Write supporting shell scripts
5. Test scripts locally
6. Add cross-platform support (bash + powershell)
7. **Self-review** - Verify hooks against both CLI and VS Code formats before finalizing

## Deliverables

### .github/hooks/hooks.json
```json
{
  "version": 1,
  "hooks": {
    "trigger": [
      {
        "type": "command",
        "bash": "./scripts/hook.sh",
        "powershell": "./scripts/hook.ps1",
        "cwd": ".",
        "timeoutSec": 30
      }
    ]
  }
}
```

### Script Template
```bash
#!/usr/bin/env bash
# Exit immediately if a command fails (-e)
# Treat unset variables as errors (-u)
# Fail pipeline if any command fails (-o pipefail)
set -euo pipefail

# Read JSON input from stdin (provided by the hook system)
INPUT=$(cat)

# Parse JSON input with jq (examples)
# SESSION_ID=$(echo "$INPUT" | jq -r '.sessionId')
# TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')

# Hook logic here

# Return JSON response (required)
echo '{"status": "success"}'
```

## Directory Structure

```
{{target_project}}/
└── .github/
    └── hooks/
        ├── hooks.json
        └── scripts/
            ├── hook-name.sh
            └── hook-name.ps1
```

## Error Handling

- If `jq` is not installed: Include fallback parsing or document jq as a prerequisite
- If script times out: Reduce work or increase `timeoutSec` (max recommended: 60s)
- If JSON parsing fails: Validate input format and log error before exiting with non-zero
- If hook file cannot be created: Check permissions and `.github/hooks/` directory exists

## Success Criteria

- [ ] `hooks.json` created at `.github/hooks/hooks.json` with `version: 1`
- [ ] All JSON syntax is valid (test with `jq . hooks.json`)
- [ ] Shell scripts are executable (`chmod +x`)
- [ ] Scripts have proper shebang (`#!/usr/bin/env bash`)
- [ ] Scripts include `set -euo pipefail` for safety
- [ ] Both bash and powershell versions provided
- [ ] Scripts tested locally with sample input

## Quality Checklist

- [ ] `version: 1` present in hooks.json
- [ ] Valid JSON syntax
- [ ] Scripts are executable
- [ ] Scripts have proper shebang
- [ ] Reasonable timeouts
- [ ] Both bash and powershell provided
- [ ] Error handling in scripts
