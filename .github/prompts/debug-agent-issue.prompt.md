---
name: debug-agent-issue
description: Troubleshoot and fix issues with GitHub Copilot agent configurations
---

# Debug Agent Issue

Diagnose and resolve problems with agent configurations.

## Problem Description
{{issue_description}}

## Affected Configuration
- **File Path**: {{config_path}}
- **Configuration Type**: {{config_type}}

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{issue_description}}` | Yes | string | Description of the problem (e.g., "agent doesn't respond", "YAML parse error") |
| `{{config_path}}` | Yes | path | Path to the problematic configuration file |
| `{{config_type}}` | No | `agent` \| `instructions` \| `prompt` \| `hooks` \| `auto` | Type of configuration; `auto` detects from extension |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## Common Issues and Solutions

### YAML/JSON Syntax Errors
| Symptom | Check | Fix |
|---------|-------|-----|
| Agent not appearing in list | Missing required `description` | Add description property |
| "Invalid YAML" error | Indentation issues | Use 2 spaces, no tabs |
| Properties not recognized | Special characters in values | Quote string values |

### Agent Not Responding
| Symptom | Check | Fix |
|---------|-------|-----|
| No response at all | `user-invocable: false` | Set to `true` for direct invocation |
| Tools not working | Missing tool in `tools` array | Add required tool |
| Subagents failing | `agents` list incomplete | Add missing subagent names |

### Instructions Not Applying
| Symptom | Check | Fix |
|---------|-------|-----|
| Rules not followed | Glob pattern wrong | Test pattern against target files |
| Wrong files matched | Pattern too broad | Use more specific pattern |
| Conflicting rules | Multiple instruction files | Check for contradictions |

### Hooks Not Executing
| Symptom | Check | Fix |
|---------|-------|-----|
| Hook not running | Script path wrong | Verify path from hooks.json cwd |
| Hook failing | Script not executable | Run `chmod +x script.sh` |
| Hook timing out | Long operation | Increase `timeoutSec` |

### Hooks Format Compatibility
| Symptom | Check | Fix |
|---------|-------|-----|
| Hooks work in CLI but not VS Code | Trigger names use CLI format | Use VS Code triggers: `SessionStart`, `Stop`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop` |
| Tool blocking not working | Using wrong output format | CLI: `{"blocked": true}`; VS Code: `hookSpecificOutput.permissionDecision` set to `"deny"` |
| Input fields not parsed | Field name mismatch | CLI: `toolName`/`toolArgs`; VS Code: `tool_name`/`tool_input` |

### Variable Syntax Issues
| Symptom | Check | Fix |
|---------|-------|-----|
| Variables not interpolated | Wrong syntax for environment | Template docs use `{{var}}`; VS Code uses `${input:var}` or `${selection}` |
| Built-in variables empty | Using template syntax | Replace `{{file}}` with VS Code built-ins like `${file}`, `${workspaceFolder}` |

## Debugging Workflow

1. **Identify the file type** from path or extension
2. **Validate syntax** - Parse YAML/JSON, check for errors
3. **Check required properties** - Ensure all mandatory fields present
4. **Verify references** - All paths, agents, tools exist
5. **Test in isolation** - Minimal reproduction of issue
6. **Apply fix** - Make smallest change to resolve
7. **Verify fix** - Confirm issue is resolved

## Error Handling

- If config file doesn't exist: Report missing file and expected location
- If syntax invalid: Provide exact line/position of error
- If issue is environmental: Document setup requirements
- If root cause unclear: Suggest diagnostic steps

## Success Criteria

- [ ] Root cause of issue identified
- [ ] Specific fix applied (or documented if manual step needed)
- [ ] Fix verified working
- [ ] No new issues introduced
- [ ] Prevention guidance provided (how to avoid recurrence)

## Deliverables

- [ ] Issue diagnosis with root cause
- [ ] Fixed configuration file (if applicable)
- [ ] Explanation of what was wrong and why
- [ ] Prevention tips for avoiding similar issues
