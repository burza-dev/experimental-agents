# Copilot Instructions for Agent Configuration Templates

## Project Overview

This repository provides **cross-project templates** for GitHub Copilot agent configurations. It contains specialized agents that help create, review, and manage:

- **Agent definitions** (`.agent.md`) - Custom Copilot agents
- **Path-specific instructions** (`.instructions.md`) - File-type specific guidance
- **Hooks** (`hooks.json` + scripts) - Custom behavior at execution points
- **Prompts** (`.prompt.md`) - Reusable task templates
- **Copilot instructions** (`copilot-instructions.md`) - Repository-wide guidance

The agents in this repository are designed to analyze a target project and create tailored agent configurations for it.

## Repository Structure

```
experimental-agents/
├── .github/
│   ├── agents/                    # Agent definitions
│   │   ├── manager.agent.md       # Orchestrator agent
│   │   ├── researcher.agent.md    # Project analyzer
│   │   ├── architect.agent.md     # Agent architecture designer
│   │   ├── manual-tester.agent.md # Configuration tester
│   │   ├── *-developer.agent.md   # Developer agents (5)
│   │   └── *-reviewer.agent.md    # Reviewer agents (5)
│   ├── instructions/              # Path-specific instructions
│   │   ├── agent-definition.instructions.md
│   │   ├── agent-skills.instructions.md
│   │   ├── context-engineering.instructions.md
│   │   ├── instructions-file.instructions.md
│   │   ├── prompt-file.instructions.md
│   │   ├── hooks.instructions.md
│   │   ├── copilot-instructions-file.instructions.md
│   │   └── markdown.instructions.md
│   ├── skills/                    # Reusable agent skills (loaded on-demand)
│   │   ├── context-map/           # Context mapping before implementation
│   │   ├── copilot-config-reference/ # Quick reference for all config file formats
│   │   ├── evidence-contract/     # Structured orchestrator-subagent communication
│   │   ├── glob-pattern-library/  # Glob patterns for instruction file applyTo fields
│   │   ├── make-skill-template/   # Meta-skill for scaffolding new skills
│   │   ├── model-recommendation/  # AI model selection guidance for agents and prompts
│   │   ├── review-and-refactor/   # Review and refactoring workflow
│   │   ├── self-review-protocol/  # Pre-completion validation checklist
│   │   ├── suggest-awesome-github-copilot-agents/ # Suggest community agents from awesome-copilot
│   │   ├── suggest-awesome-github-copilot-instructions/ # Suggest community instructions
│   │   ├── suggest-awesome-github-copilot-skills/ # Suggest community skills
│   │   └── yaml-frontmatter-validator/ # YAML frontmatter schema validation
│   ├── prompts/                   # Reusable prompts
│   │   ├── create-agent.prompt.md
│   │   ├── create-copilot-instructions.prompt.md
│   │   ├── create-hooks.prompt.md
│   │   ├── create-instructions.prompt.md
│   │   ├── create-prompts.prompt.md
│   │   ├── debug-agent-issue.prompt.md
│   │   ├── onboard-project.prompt.md
│   │   ├── optimize-agent.prompt.md
│   │   ├── review-configuration.prompt.md
│   │   └── validate-configuration.prompt.md
│   └── copilot-instructions.md    # This file
├── awesome-copilot/               # Community collection of agents, skills, and instructions (git submodule)
└── README.md
```

> **Note:** The `.github/hooks/` directory does not currently exist. Hooks documentation and agents support creating hooks for target projects.

## Multi-Agent Workflow

This project uses a **manager-subagent pattern** for creating agent configurations:

```
User Request
     ↓
  manager
     ↓
  ┌──────────────────────────────────────┐
  │           Research Phase             │
  │  researcher → analyze target project │
  └──────────────────────────────────────┘
     ↓
  ┌──────────────────────────────────────┐
  │         Architecture Phase           │
  │  architect → design agent plan       │
  └──────────────────────────────────────┘
     ↓
  ┌──────────────────────────────────────┐
  │           Creation Phase             │
  │  copilot-instructions-developer      │
  │  agent-definition-developer          │
  │  instructions-developer              │
  │  prompts-developer                   │
  │  hooks-developer                     │
  └──────────────────────────────────────┘
     ↓
  ┌──────────────────────────────────────┐
  │           Review Phase               │
  │  *-reviewer for each created file    │
  │                                      │
  │  If CHANGES REQUIRED:               │
  │    developer fixes → reviewer        │
  │    re-reviews (loop until APPROVED)  │
  │  Max 3 cycles; then escalate to user │
  └──────────────────────────────────────┘
     ↓
  ┌──────────────────────────────────────┐
  │           Testing Phase              │
  │  manual-tester → validate configs    │
  └──────────────────────────────────────┘
     ↓
  Done
```

### Available Agents

| Agent | Purpose |
|-------|---------|
| `manager` | Orchestrates workflow, delegates to specialists |
| `researcher` | Analyzes target project structure and patterns |
| `architect` | Designs agent architectures for target projects (agents, relationships, handoff patterns, tool assignments, workflows) |
| `manual-tester` | Validates agent configurations by simulating real-world usage scenarios (end-to-end workflow testing, cross-reference verification, coverage gap analysis, handoff chain verification) |
| `agent-definition-developer` | Creates `.agent.md` files |
| `agent-definition-reviewer` | Reviews agent definitions |
| `instructions-developer` | Creates `.instructions.md` files |
| `instructions-reviewer` | Reviews instruction files |
| `hooks-developer` | Creates `hooks.json` and scripts |
| `hooks-reviewer` | Reviews hooks configuration |
| `prompts-developer` | Creates `.prompt.md` files |
| `prompts-reviewer` | Reviews prompt files |
| `copilot-instructions-developer` | Creates `copilot-instructions.md` |
| `copilot-instructions-reviewer` | Reviews copilot instructions |

## Critical Rules

### Quality Standards

1. **Valid Syntax** - All YAML frontmatter must be valid
2. **Accurate Descriptions** - Agent descriptions must be specific and under 200 chars
3. **Minimal Tools** - Use only necessary tools (principle of least privilege)
4. **Actionable Instructions** - All instructions must be specific and actionable
5. **No Overlaps** - Agents and instructions should not have overlapping responsibilities
6. **Self-review required** - Use the `self-review-protocol` skill before completing work
7. **Structured communication** - Use the `evidence-contract` skill for orchestrator-subagent exchanges
8. **File management** - Developer agents need the `execute` tool for terminal operations
9. **TDD workflow** - Created agents should promote test-driven development practices
10. **Cross-reference verification** - All file and agent references must be validated against actual paths

### File Naming

| File Type | Pattern | Example |
|-----------|---------|---------|
| Agent | `name.agent.md` | `test-writer.agent.md` |
| Instructions | `name.instructions.md` | `python.instructions.md` |
| Prompt | `name.prompt.md` | `add-feature.prompt.md` |
| Hooks | `hooks.json` | `hooks.json` |
| Skill | `skill-name/SKILL.md` | `self-review-protocol/SKILL.md` |

### YAML Frontmatter

```yaml
# Agent definition
---
name: agent-name                 # Optional, defaults to filename
description: Brief desc          # Required, max 200 chars
tools: ["read", "edit"]          # Optional, omit for all tools
agents: ["sub-agent-1"]          # Optional, list of subagents
handoffs:                        # Optional, workflow transitions
  - label: Next step
    agent: next-agent
    prompt: Context for the handoff
    send: false
user-invocable: true             # Optional, whether user can invoke directly
disable-model-invocation: false  # Optional, whether model can invoke
argument-hint: Describe what to do  # Optional, hint text in chat input
model: "Claude Sonnet 4.5"      # Optional, AI model (or array for fallback list)
target: "vscode"                 # Optional, "vscode" or "github-copilot"
mcp-servers:                     # Optional, MCP servers (target: github-copilot)
  server-name:
    url: https://example.com/mcp
---

# Instructions
---
applyTo: "**/*.py"        # Required glob pattern
name: instruction-name    # Optional, display name
description: Brief desc   # Optional, purpose description
excludeAgent: "code-review"  # Optional
---

# Prompt
---
name: prompt-name         # Recommended, defaults to filename
description: Brief desc   # Recommended
agent: agent-name         # Optional, agent mode for execution
argument-hint: Describe input  # Optional, hint text in chat input
tools: ["read", "edit"]          # Optional, tools for this prompt
model: "gpt-4"                   # Optional, model to use
---
```

#### Handoff Properties

| Property | Required | Description |
|----------|----------|-------------|
| `label` | Yes | Display name for the handoff action |
| `agent` | Yes | Target agent name (without `.agent.md`) |
| `prompt` | No | Instructions/context passed to target agent |
| `send` | No | `true` to send immediately, `false` for confirmation |
| `model` | No | Specific model to use for the handoff |

## Common Tasks

### Onboard a New Project

0. Check for existing `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` in target project to understand prior agent configurations
1. Use `manager` agent or `onboard-project` prompt
2. Provide target project path
3. Manager delegates to:
   - `researcher` → analyze project
   - `copilot-instructions-developer` → create repo instructions
   - `agent-definition-developer` → create agents
   - `instructions-developer` → create file instructions
   - `prompts-developer` → create prompts
4. Reviewers validate each file
   - If issues found: developer fixes → reviewer re-reviews (loop until APPROVED)
5. Self-review phase: subagents report configuration improvement suggestions
6. All files placed in target project's `.github/`

### Create a Single Agent

1. Use `agent-definition-developer` or `create-agent` prompt
2. Provide agent role and purpose
3. Developer generates `.agent.md` file
4. `agent-definition-reviewer` validates → if issues, developer fixes → re-review (loop until APPROVED)

### Review Existing Configuration

1. Use `review-configuration` prompt
2. Reviewers analyze all config files
3. Report issues by severity
4. Apply fixes as needed
5. Re-review to confirm fixes are correct (loop until all issues resolved)

## Verification Commands

```bash
# Validate YAML frontmatter
grep -A5 "^---" file.agent.md

# Check for required properties
grep "description:" file.agent.md

# List all agents
ls .github/agents/*.agent.md

# List all instructions
ls .github/instructions/*.instructions.md
```

## Hooks Format

Hooks use CLI format with `version: 1`:

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [{ "type": "command", "bash": "./scripts/start.sh", "powershell": "./scripts/start.ps1" }]
  }
}
```

### Available Triggers

| Trigger | When |
|---------|------|
| `sessionStart` | New or resumed session begins |
| `sessionEnd` | Session completes |
| `userPromptSubmitted` | User submits a prompt |
| `preToolUse` | Before tool execution (can return `permissionDecision`) |
| `postToolUse` | After tool completes |
| `agentStop` | Main agent stops without error |
| `subagentStop` | Subagent completes |
| `errorOccurred` | Error during agent execution |

### Hook Command Properties

| Property | Required | Description |
|----------|----------|-------------|
| `type` | Yes | Must be `"command"` |
| `bash` | Yes* | Bash command or script path |
| `powershell` | Yes* | PowerShell command/script |
| `cwd` | No | Working directory |
| `timeoutSec` | No | Timeout in seconds (default: 30) |
| `env` | No | Environment variables object |
| `comment` | No | Documentation string |

*At least one of `bash` or `powershell` required.

Agents can also define agent-scoped hooks inline via the `hooks` frontmatter property (VS Code Preview).

## Forbidden Practices

- ❌ Agents with overlapping responsibilities
- ❌ Missing `description` in agent definitions
- ❌ Generic instructions ("be helpful")
- ❌ Instructions exceeding 30,000 characters
- ❌ Glob patterns that match unintended files
- ❌ CLI-format hooks without `version: 1`
- ❌ Scripts without error handling
