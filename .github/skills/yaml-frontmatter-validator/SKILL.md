---
name: yaml-frontmatter-validator
description: 'Validate YAML frontmatter schemas for all GitHub Copilot configuration file types. Use when creating, reviewing, or debugging .agent.md, .instructions.md, .prompt.md, or SKILL.md files. Provides complete field schemas, type constraints, and common error patterns.'
---

# YAML Frontmatter Validator

Validate frontmatter for all Copilot configuration file types against their canonical schemas.

## How to Use

1. Identify the file type being validated
2. Check all required fields are present
3. Verify field values match type constraints
4. Cross-reference agent/file names against actual paths

## Schemas

### Agent Definition (`.agent.md`)

| Field | Required | Type | Constraints |
|-------|----------|------|------------|
| `description` | Yes | string | Max 200 characters. Must be specific and actionable. |
| `name` | No | string | Defaults to filename (without `.agent.md`). |
| `tools` | No | string[] | Valid: `read`, `edit`, `search`, `web`, `execute`, `agent`, `todo`, `"server-name/*"`, `"server-name/tool-name"`. Omit for all tools. |
| `agents` | No | string[] | Each must match an existing `.agent.md` filename (without extension). |
| `handoffs` | No | object[] | Each entry: `label` (required string), `agent` (required string), `prompt` (optional string), `send` (optional boolean), `model` (optional string). |
| `user-invocable` | No | boolean | Default: `true`. Set `false` for subagent-only agents. |
| `disable-model-invocation` | No | boolean | Default: `false`. Prevents automatic invocation as subagent. |
| `argument-hint` | No | string | Placeholder text shown in chat input. |
| `model` | No | string or string[] | AI model name, or prioritized fallback array. |
| `target` | No | string | `"vscode"` or `"github-copilot"`. |
| `hooks` | No | object | Agent-scoped hooks (VS Code Preview). |
| `mcp-servers` | No | object | MCP server configurations (target: github-copilot). |

**Deprecated fields:**

| Field | Status | Migration |
|-------|--------|-----------|
| `infer` | RETIRED | Use `user-invocable` + `disable-model-invocation` instead. |

### Instructions File (`.instructions.md`)

| Field | Required | Type | Constraints |
|-------|----------|------|------------|
| `applyTo` | Yes | string (glob) | Must match intended files. Test with `ls` or `find`. |
| `name` | No | string | Display name for the instruction set. |
| `description` | No | string | Purpose description. |
| `excludeAgent` | No | string | `"code-review"` or `"coding-agent"`. Excludes this instruction from specified agent type. |

### Prompt File (`.prompt.md`)

| Field | Required | Type | Constraints |
|-------|----------|------|------------|
| `name` | Recommended | string | Defaults to filename (without `.prompt.md`). |
| `description` | Recommended | string | Brief purpose description. |
| `agent` | No | string | Agent to execute in agent mode. Must match existing agent name. |
| `argument-hint` | No | string | Placeholder hint text for user input. |
| `tools` | No | string[] | Same valid values as agent `tools`. |
| `model` | No | string | AI model to use for this prompt. |

### Skill File (`SKILL.md`)

| Field | Required | Type | Constraints |
|-------|----------|------|------------|
| `name` | Recommended | string | Lowercase, kebab-case. Must match parent directory name. |
| `description` | Recommended | string | When to use this skill. Include trigger phrases. |

## Common Validation Errors

### Critical (Will break functionality)

| Error | Example | Fix |
|-------|---------|-----|
| Missing `description` in agent | `---`<br>`tools: ["read"]`<br>`---` | Add `description: "Brief purpose"` |
| Missing `applyTo` in instructions | `---`<br>`name: python`<br>`---` | Add `applyTo: "**/*.py"` |
| Invalid tool name | `tools: ["terminal"]` | Use `execute` instead of `terminal` |
| Non-existent agent reference | `agents: ["code-writer"]` when no `code-writer.agent.md` exists | Create the agent or fix the reference |
| Invalid YAML syntax | Missing quotes around glob with `{}` | `applyTo: "**/*.{ts,tsx}"` (must quote) |

### Warning (May cause unexpected behavior)

| Error | Example | Fix |
|-------|---------|-----|
| Description over 200 chars | Long descriptions get truncated | Shorten to under 200 characters |
| Overly broad glob | `applyTo: "**/*"` | Narrow to specific file types |
| Using deprecated `infer` | `infer: false` | Replace with `disable-model-invocation: true` |
| Duplicate agent names | Two files with same `name:` field | Use unique names |
| Missing handoff target | `agent: "helper"` in handoff but no `helper.agent.md` | Create the target agent |

### Info (Style recommendations)

| Issue | Recommendation |
|-------|---------------|
| Agent without `argument-hint` | Add hint to guide users on expected input |
| Skill name doesn't match directory | Rename `name:` to match parent folder name |
| Prompt without `description` | Add description for discoverability |

## Cross-Reference Validation

When validating a complete configuration set, verify:

1. **Agent → Agent references**: Every name in `agents:` and `handoffs[].agent` has a matching `.agent.md` file
2. **Prompt → Agent references**: Every `agent:` in prompt frontmatter matches an existing agent
3. **Instruction glob coverage**: No two instruction files have overlapping `applyTo` patterns that could conflict
4. **Skill directory naming**: `name:` field matches the parent directory name
5. **Tool consistency**: Agents don't request tools they never use in their instructions

## Validation Procedure

```
1. Read the file's YAML frontmatter (between `---` delimiters)
2. Parse YAML — report any syntax errors
3. Identify file type from extension
4. Check all REQUIRED fields are present
5. Validate field values against type constraints
6. Check for deprecated fields — suggest migration
7. Cross-reference agent/file names against filesystem
8. Report: VALID (no issues) | WARNINGS (non-blocking) | INVALID (blocking issues)
```
