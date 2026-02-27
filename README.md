# Agent Configuration Templates

Cross-project templates for GitHub Copilot agent configurations. This repository provides specialized agents that analyze target projects and create tailored configurations including agents, instructions, hooks, and prompts.

## Overview

This repository contains a **multi-agent system** designed to onboard any project to GitHub Copilot by creating:

| Configuration Type | File Pattern | Description |
|-------------------|--------------|-------------|
| Agent Definitions | `.agent.md` | Custom Copilot agents with specific roles |
| Path Instructions | `.instructions.md` | File-type specific coding guidance |
| Hooks | `hooks.json` | Custom behavior at agent execution points |
| Prompts | `.prompt.md` | Reusable task templates |
| Copilot Instructions | `copilot-instructions.md` | Repository-wide guidance |

## Quick Start

### Using the Manager Agent

The `manager` agent orchestrates the entire onboarding process:

1. Open GitHub Copilot Chat
2. Select the `manager` agent
3. Provide your request:
   ```
   Onboard the project at /path/to/my-project to GitHub Copilot.
   Create agents, instructions, and prompts appropriate for this project.
   ```

### Using Individual Prompts

For specific tasks, use the provided prompts:

| Prompt | Purpose |
|--------|---------|
| `onboard-project` | Complete project onboarding |
| `create-agent` | Create a single agent definition |
| `create-copilot-instructions` | Create repository instructions |
| `create-instructions` | Create path-specific instructions |
| `create-hooks` | Create hooks configuration |
| `create-prompts` | Create reusable prompts |
| `debug-agent-issue` | Troubleshoot agent configuration problems |
| `optimize-agent` | Improve agent effectiveness |
| `review-configuration` | Review existing configuration |
| `validate-configuration` | Validate syntax and schema compliance |

## Agent Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         manager                             │
│              Orchestrates workflow, delegates               │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌─────────────────┐
│  researcher   │   │   developers    │   │    reviewers    │
│ Analyzes      │   │ Create config   │   │ Validate        │
│ projects      │   │ files           │   │ quality         │
└───────────────┘   └─────────────────┘   └─────────────────┘
```

### Agent Reference

| Agent | Role |
|-------|------|
| `manager` | Orchestrates workflow, delegates to specialists |
| `researcher` | Analyzes target project structure and conventions |
| `agent-definition-developer` | Creates `.agent.md` files |
| `agent-definition-reviewer` | Reviews agent definitions |
| `instructions-developer` | Creates `.instructions.md` files |
| `instructions-reviewer` | Reviews instruction files |
| `hooks-developer` | Creates `hooks.json` and scripts |
| `hooks-reviewer` | Reviews hooks configuration |
| `prompts-developer` | Creates `.prompt.md` files |
| `prompts-reviewer` | Reviews prompt files |
| `copilot-instructions-developer` | Creates `copilot-instructions.md` |
| `copilot-instructions-reviewer` | Reviews repository instructions |

## Repository Structure

```
.github/
├── agents/                              # Agent definitions
│   ├── manager.agent.md                 # Main orchestrator
│   ├── researcher.agent.md              # Project analyzer
│   ├── agent-definition-developer.agent.md
│   ├── agent-definition-reviewer.agent.md
│   ├── instructions-developer.agent.md
│   ├── instructions-reviewer.agent.md
│   ├── hooks-developer.agent.md
│   ├── hooks-reviewer.agent.md
│   ├── prompts-developer.agent.md
│   ├── prompts-reviewer.agent.md
│   ├── copilot-instructions-developer.agent.md
│   └── copilot-instructions-reviewer.agent.md
├── instructions/                        # Path-specific instructions
│   ├── agent-definition.instructions.md
│   ├── instructions-file.instructions.md
│   ├── prompt-file.instructions.md
│   ├── hooks.instructions.md
│   ├── copilot-instructions-file.instructions.md
│   └── markdown.instructions.md
├── prompts/                             # Reusable prompts
│   ├── create-agent.prompt.md
│   ├── create-copilot-instructions.prompt.md
│   ├── create-hooks.prompt.md
│   ├── create-instructions.prompt.md
│   ├── create-prompts.prompt.md
│   ├── debug-agent-issue.prompt.md
│   ├── onboard-project.prompt.md
│   ├── optimize-agent.prompt.md
│   ├── review-configuration.prompt.md
│   └── validate-configuration.prompt.md
├── hooks/                               # Hooks configuration
│   ├── hooks.json
│   └── scripts/
│       ├── log-prompt.ps1
│       ├── log-prompt.sh
│       ├── log-session.ps1
│       ├── log-session.sh
│       ├── log-tool.ps1
│       ├── log-tool.sh
│       ├── on-error.ps1
│       ├── on-error.sh
│       ├── validate-tool.ps1
│       └── validate-tool.sh
└── copilot-instructions.md              # Repository instructions
templates/                               # Configuration templates
└── coding/                              # Coding agent templates
    └── .github/
        ├── agents/
        ├── instructions/
        ├── prompts/
        ├── skills/                  # Agent skills (VS Code feature)
        └── copilot-instructions.md
```

## Workflow

### Complete Project Onboarding

```
1. Research Phase
   └── researcher analyzes project structure, tech stack, conventions

2. Creation Phase
   ├── copilot-instructions-developer → repository instructions
   ├── agent-definition-developer → agent definitions
   ├── instructions-developer → path-specific instructions
   ├── prompts-developer → reusable prompts
   └── hooks-developer → hooks (if needed)

3. Review Phase
   └── Each *-reviewer validates corresponding files

4. Completion
   └── All files in target project's .github/
```

### Expected Output

For a typical project, the agents create:

```
my-project/.github/
├── copilot-instructions.md      # Project overview, build commands
├── agents/
│   ├── manager.agent.md         # Project workflow orchestrator
│   ├── implementer.agent.md     # Code implementation
│   ├── test-writer.agent.md     # Test creation
│   └── reviewer.agent.md        # Code review
├── instructions/
│   ├── python.instructions.md   # Python coding standards
│   ├── tests.instructions.md    # Test file conventions
│   └── config.instructions.md   # Config file rules
└── prompts/
    ├── add-feature.prompt.md    # Feature implementation
    ├── fix-bug.prompt.md        # Bug fixing
    └── add-tests.prompt.md      # Test coverage
```

## Configuration File Formats

### Agent Definition (`.agent.md`)

```yaml
---
name: agent-name
description: Brief description (required, max 200 chars)
tools: ["read", "edit", "search"]
---

## Instructions

Clear, actionable instructions for the agent.
```

### Instructions File (`.instructions.md`)

```yaml
---
applyTo: "**/*.py"
---

# Python File Rules

Rules for Python files...
```

### Prompt File (`.prompt.md`)

```yaml
---
name: add-feature
description: Add a new feature
---

# Add Feature

## Variables
- {{feature_name}}: Name of the feature

## Steps
1. Analyze requirements
2. Implement feature
3. Write tests
```

### Hooks (`hooks.json`)

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "type": "command",
        "bash": "echo 'Session started'",
        "timeoutSec": 10
      }
    ]
  }
}
```

> **Note:** This shows the Copilot CLI hook format. VS Code also supports a canonical format using PascalCase triggers (e.g., `SessionStart`) and the `command` property. See [Hooks documentation](https://code.visualstudio.com/docs/copilot/customization/hooks) for details.

## Platform Support

| Platform | Status |
|----------|--------|
| GitHub Copilot Chat | **Supported** |
| VS Code Copilot | **Supported** |
| JetBrains IDEs | **Supported** |
| GitHub Copilot CLI | **Supported** |

## Quality Standards

- **TDD workflow** — Developer agents should write tests before implementation when feasible
- **Self-review protocol** — Each developer agent has a corresponding reviewer agent that validates output
- **File operations** — Developer agents include the `execute` tool for file creation and modification
- **Minimal tools** — Agents request only the tools they need (principle of least privilege)
- **No overlapping responsibilities** — Each agent has a distinct, non-overlapping role

## Documentation

- [Custom Agents (VS Code)](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
- [Repository Instructions (GitHub)](https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot)
- [Custom Instructions (VS Code)](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [Agent Skills (VS Code)](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Hooks (VS Code)](https://code.visualstudio.com/docs/copilot/customization/hooks)
- [Prompt Files (VS Code)](https://code.visualstudio.com/docs/copilot/customization/prompt-files)

