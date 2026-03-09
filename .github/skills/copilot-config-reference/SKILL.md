---
name: copilot-config-reference
description: Reference guide for GitHub Copilot configuration file formats including agent definitions, instructions, prompts, hooks, and skills. Use when creating, editing, or reviewing .agent.md, .instructions.md, .prompt.md, hooks.json, or SKILL.md files. Covers YAML frontmatter schemas, tool names, handoff patterns, glob syntax, and validation rules.
---

# Copilot Configuration Reference

Quick reference for all GitHub Copilot customization file formats.

## Agent Definitions (`.agent.md`)

### Frontmatter Schema

```yaml
---
name: agent-name                    # Optional, defaults to filename
description: What the agent does    # REQUIRED, max 200 chars
tools: ["read", "edit"]             # Optional, omit for all tools
agents: ["sub-agent-1"]             # Optional, subagent list
model: "Claude Sonnet 4.5"         # Optional, string or array for fallback list
target: "vscode"                    # Optional, "vscode" or "github-copilot"
user-invocable: true                # Optional, true = user can invoke
disable-model-invocation: false     # Optional, prevents auto-invocation
argument-hint: Describe task        # Optional, chat input hint text
handoffs:                           # Optional, workflow transitions
  - label: Next step
    agent: target-agent
    prompt: Context for handoff
    send: false
mcp-servers:                        # Optional, org/enterprise only
  server-name:
    url: https://example.com/mcp
hooks:                              # Optional, VS Code Preview, agent-scoped hooks
  sessionStart:
    - type: command
      bash: ./scripts/start.sh
---
```

### Tool Names

| Tool | Aliases | Purpose |
|------|---------|---------|
| `read` | Read, NotebookRead, view | Read file contents |
| `edit` | Edit, MultiEdit, Write | Edit/create files |
| `search` | Grep, Glob | Search workspace |
| `web` | WebSearch, WebFetch | Web search and fetch |
| `execute` | shell, Bash, powershell | Run terminal commands |
| `agent` | custom-agent, Task | Invoke subagents |
| `todo` | TodoWrite | Manage task lists |
| `mcp_*` | (pattern-matched) | MCP server tools |

> **Note**: The `web` tool is not applicable for the GitHub.com coding agent. Unrecognized tool names are silently ignored for cross-environment compatibility.

### Handoff Properties

| Property | Required | Type | Description |
|----------|----------|------|-------------|
| `label` | Yes | string | Button text shown to user |
| `agent` | Yes | string | Target agent name (no `.agent.md`) |
| `prompt` | No | string | Pre-filled prompt for target |
| `send` | No | boolean | `true` = auto-send, `false` = confirm |
| `model` | No | string | Model override for this handoff |

## Instructions (`.instructions.md`)

### Frontmatter Schema

```yaml
---
applyTo: "**/*.py"              # REQUIRED, glob pattern(s)
name: python-standards           # Optional, display name
description: Python conventions  # Optional
excludeAgent: "code-review"      # Optional, "code-review" or "coding-agent"
---
```

### Glob Patterns

| Pattern | Matches | Doesn't Match |
|---------|---------|---------------|
| `*.py` | `app.py` | `src/app.py` |
| `**/*.py` | `app.py`, `src/app.py` | `app.js` |
| `src/**/*.py` | `src/app.py` | `app.py` |
| `**/*.{ts,tsx}` | `app.ts`, `x.tsx` | `app.js` |
| `**/test_*.py` | `test_app.py` | `app_test.py` |

Multiple patterns: `applyTo: "**/*.ts,**/*.tsx,**/*.js"`

## Prompts (`.prompt.md`)

### Frontmatter Schema

```yaml
---
name: create-component              # Recommended, lowercase-hyphens
description: Create a UI component  # Recommended
agent: "agent-name"                  # Optional, execution agent
tools: ["read", "edit"]              # Optional
model: "gpt-4"                       # Optional
argument-hint: Component name        # Optional, input hint
---
```

### Variable Syntax

| Syntax | Processor | Example |
|--------|-----------|---------|
| `${input:name}` | VS Code (prompts user) | `${input:componentName}` |
| `${input:name:default}` | VS Code (with default) | `${input:type:form}` |
| `${selection}` | VS Code (editor selection) | Current selected text |
| `${file}` | VS Code (current file) | Active file path |
| `${workspaceFolder}` | VS Code (workspace root) | Root directory |
| `{{variable}}` | Documentation only | Not processed by VS Code |

## Hooks (`hooks.json`)

### Structure

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [{ "type": "command", "bash": "./script.sh" }]
  }
}
```

### Triggers

| CLI (camelCase) | When |
|-----------------|------|
| `sessionStart` | Session begins |
| `sessionEnd` | Session ends |
| `userPromptSubmitted` | User sends prompt |
| `preToolUse` | Before tool execution |
| `postToolUse` | After tool execution |
| `agentStop` | Main agent stops without error |
| `subagentStop` | Subagent completes |
| `errorOccurred` | On error |

### Hook Command Properties

| Property | Required | Description |
|----------|----------|-------------|
| `type` | Yes | Must be `"command"` |
| `bash` | Yes* | Bash command or script path |
| `powershell` | Yes* | PowerShell command/script |
| `cwd` | No | Working directory |
| `timeoutSec` | No | Timeout (default: 30) |
| `env` | No | Environment variables |
| `comment` | No | Documentation string |

*At least one of `bash` or `powershell` required.

## Skills (`SKILL.md`)

### Frontmatter Schema

```yaml
---
name: skill-name          # REQUIRED, lowercase-hyphens, max 64 chars
description: What + When  # REQUIRED, max 1024 chars
license: Apache-2.0       # Optional
---
```

### Directory Structure

```
.github/skills/<skill-name>/
├── SKILL.md              # Required
├── scripts/              # Optional executables
├── references/           # Optional docs loaded into context
├── assets/               # Optional static files (used as-is)
└── templates/            # Optional scaffolds (AI modifies)
```

### Locations

| Scope | Path |
|-------|------|
| Project | `.github/skills/<skill-name>/SKILL.md` |
| Personal | `~/.copilot/skills/<skill-name>/SKILL.md` |
| Claude compat | `.claude/skills/<skill-name>/SKILL.md` |

### Loading Levels

| Level | Loads | When |
|-------|-------|------|
| Discovery | `name` + `description` | Always |
| Instructions | Full SKILL.md body | When prompt matches description |
| Resources | Scripts, references | Only when explicitly referenced |

## Multi-Agent Design Principles

### Role Types

| Type | Tools | Edits Files? | Invokes Agents? |
|------|-------|-------------|-----------------|
| Orchestrator | `read`, `agent`, `todo` | No | Yes |
| Researcher | `read`, `search`, `web` | No | No |
| Architect | `read`, `search`, `web` | No | No |
| Developer | `read`, `edit`, `search`, `execute` | Yes | No |
| Reviewer | `read`, `search` | No | No |
| Tester | `read`, `search` | No | No |

### Naming Conventions

- Lowercase, hyphens for spaces: `test-writer.agent.md`
- Role-based, not person-based: `code-reviewer` not `john-agent`
- Specific, not generic: `api-test-writer` not `helper`
