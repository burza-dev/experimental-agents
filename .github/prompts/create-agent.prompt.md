---
name: create-agent
description: Create a custom GitHub Copilot agent definition for a specific role
---

# Create Agent Definition

Create a new GitHub Copilot agent definition file.

## Agent Details
- **Role**: {{agent_role}}
- **Purpose**: {{agent_purpose}}
- **Target Project**: {{target_project}}
- **Agent Name**: {{agent_name}}

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{agent_role}}` | Yes | string | The role this agent fulfills (e.g., "code reviewer", "test writer") |
| `{{agent_purpose}}` | Yes | string | What the agent accomplishes for the project |
| `{{target_project}}` | Yes | path | Absolute path to the target project directory |
| `{{agent_name}}` | Yes | lowercase-hyphenated | Filename for the agent (e.g., "code-reviewer" → `code-reviewer.agent.md`) |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## Requirements

### Tools Needed
Select appropriate tools (check only what the agent needs - principle of least privilege):
- [ ] `read` - Read file contents (most agents need this)
- [ ] `edit` - Modify files (only for agents that create/change files)
- [ ] `search` - Search codebase (for discovery and analysis tasks)
- [ ] `web` - Fetch web resources (only if external docs needed)
- [ ] `execute` - Run shell commands (only if running builds/tests/scripts)
- [ ] `agent` - Delegate to subagents (only for orchestrator/manager agents)
- [ ] `todo` - Manage task lists (for multi-step workflows)

**Tool Selection Guidance:**
- Start minimal - add tools only when clearly needed
- `read` + `search` covers most analysis-only agents
- Add `edit` only if the agent creates or modifies files
- Add `execute` only if the agent runs commands

### Optional Agent Properties
Consider including these optional YAML properties when applicable:
- `argument-hint` - Hint text shown to users when invoking the agent
- `mcp-servers` - MCP server configurations for specialized tool access

### Scope
Define what the agent does and does not do.

## Workflow

1. Analyze the target project for context
2. Define agent's specific responsibilities
3. Select minimum necessary tools
4. Write clear, actionable instructions
5. Add error handling guidance
6. Include completion report format
7. **Self-review** - Verify the agent definition against all quality criteria before finalizing

## Deliverable

Create `.github/agents/{{agent_name}}.agent.md` with:
- Valid YAML frontmatter
- Clear description (max 200 chars)
- Specific, actionable instructions
- Scope boundaries
- Error recovery guidance
- Completion report format
- **Self-review section** - Agent should verify its own output quality before reporting
- **Quality gate checklist** - Explicit pass/fail criteria for the agent's deliverables

## Error Handling

- If target project cannot be accessed: Report path error and request valid path
- If agent role conflicts with existing agents: List overlapping agents and ask for clarification
- If tools selection is unclear: Default to minimal set (`read`, `search`) and note this in output
- If YAML validation fails: Fix syntax and re-validate before completing

## Success Criteria

- [ ] Agent file created with valid YAML frontmatter
- [ ] `description` is under 200 characters
- [ ] `tools` list includes only necessary tools
- [ ] Instructions are specific and actionable (no generic phrases)
- [ ] Scope boundaries clearly defined
- [ ] Error handling section included in agent definition
- [ ] No responsibility overlap with existing agents

## Quality Checklist

- [ ] `description` is specific and accurate
- [ ] `tools` list is minimal but sufficient
- [ ] Instructions are actionable
- [ ] Scope is clearly defined
- [ ] Error handling included
- [ ] Examples provided where helpful
