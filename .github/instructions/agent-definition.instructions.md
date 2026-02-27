---
applyTo: "**/*.agent.md"
---

# Agent Definition File Rules

## File Structure

Agent definition files MUST have:
1. YAML frontmatter enclosed in `---`
2. Markdown body with agent instructions

```markdown
---
name: agent-name
description: Brief description (required, max 200 chars)
tools: ["tool1", "tool2"]
---

## Agent Instructions

Instructions for the agent...
```

## YAML Frontmatter Requirements

### Required Properties
- `description` - What the agent does, max 200 characters

### Optional Properties
- `name` - Defaults to filename, lowercase with hyphens
- `tools` - Array of tool names, omit for all tools
- `agents` - Array of subagent names for orchestrators
- `handoffs` - Array of handoff configurations
- `model` - Specific model to use (VS Code/JetBrains only)
- `target` - `"vscode"` or `"github-copilot"`
- `user-invokable` - `true` for user-facing, `false` for subagents
- `disable-model-invocation` - Prevents direct model invocation
- `argument-hint` - Hint text shown in chat input field for the agent
- `mcp-servers` - MCP server configurations (for `target: github-copilot` agents)

> **Deprecated**: The `infer` property is deprecated. It has been replaced by
> `user-invokable` and `disable-model-invocation`.

### Tool Names

| Tool | Purpose |
|------|--------|
| `read` | Read file contents and communications from subagents (crucial for orchestrators) |
| `edit` | Edit/create files |
| `search` | Search workspace |
| `web` | Web: fetch and search in GitHub repositories |
| `execute` | Execute terminal commands (including removal of files) |
| `agent` | Invoke other agents |
| `todo` | Manage tasks |
| `mcp_*` | MCP tools (pattern-matched) |

> **Note**: Tool names may evolve; unrecognized tools are silently ignored.

Use minimal tools following the principle of least privilege.

## Naming Conventions

- **File name**: `agent-name.agent.md` (lowercase, hyphens)
- **Agent name**: Same as filename without extension

Examples:
- ✅ `test-coverage-analyzer.agent.md`
- ✅ `api-documentation-writer.agent.md`
- ❌ `TestAgent.agent.md` (no PascalCase)
- ❌ `my agent.agent.md` (no spaces)

## Instructions Content

### Required Sections
- Purpose/role statement
- Scope and responsibilities
- Workflow or process steps

### Recommended Sections
- Output format specification
- Error handling guidance
- Completion report format
- Quality checklist

### Forbidden
- Generic instructions ("be helpful")
- Overlapping responsibilities with other agents
- Instructions exceeding 30,000 characters

## Common Agent Role Types

When designing multi-agent systems, agents typically fall into these categories:

| Role Type | Purpose | Examples |
|-----------|---------|---------|
| Orchestrator | Coordinates workflow, delegates to specialists | `manager` |
| Researcher | Analyzes project structure and patterns | `researcher` |
| Architect | Designs agent architectures, relationships, handoff patterns, tool assignments, and workflows | `architect` |
| Developer | Creates or modifies files and implementations | `implementer`, `test-writer` |
| Reviewer | Validates quality of created artifacts | `code-reviewer` |
| Tester | Validates configurations by simulating real-world usage scenarios | `manual-tester` |

### Standard Workflow Phases

Multi-agent workflows typically follow these phases:

1. **Research** — Analyze the target project
2. **Architecture** — Design agent structure, relationships, and handoff patterns
3. **Creation** — Create files and implementations
4. **Review** — Validate quality of deliverables
5. **Testing** — End-to-end workflow testing, cross-reference verification, coverage gap analysis

Each phase may involve one or more specialized agents. Orchestrator agents coordinate transitions between phases using handoffs.

## Handoff Configuration

Handoffs allow agents to delegate work to other agents.

### Handoff Properties

| Property | Required | Description |
|----------|----------|-------------|
| `label` | Yes | Display name for the handoff action |
| `agent` | Yes | Target agent name (without `.agent.md`) |
| `prompt` | No | Instructions/context passed to target agent |
| `send` | No | `true` to send immediately, `false` for confirmation |
| `model` | No | Language model for handoff execution |

### Example

```yaml
handoffs:
  - label: Run tests
    agent: test-runner
    prompt: Execute test suite for the modified files
    send: true
  - label: Review code
    agent: code-reviewer
    send: false
```

### Agent Invocation

Agents can also be invoked using `@agent-name` syntax in prompts:

```markdown
@test-runner Run unit tests for the auth module
@code-reviewer Check this implementation
```

## Quality Standards

- Description must be specific and actionable
- Tools list should be minimal but sufficient
- Instructions must have clear boundaries
- Include error recovery guidance
- Provide completion report format
