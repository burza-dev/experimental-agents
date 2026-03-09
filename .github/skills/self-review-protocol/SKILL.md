---
name: self-review-protocol
description: Self-review checklist and quality gates for agents completing work. Use when finishing a task, before reporting completion, or when asked to verify your own output quality. Covers syntax validation, cross-reference checking, placeholder detection, and completion attestation.
---

# Self-Review Protocol

Before reporting any task as complete, execute ALL checks below. Skip nothing.

## Pre-Completion Checklist

### 1. Re-Read All Output

- Re-read every file you created or modified end-to-end
- Verify content matches the original intent and requirements
- Confirm no accidental truncation or corruption

### 2. Validate Syntax

| File Type | Validation |
|-----------|------------|
| `.agent.md` | YAML frontmatter parses correctly, `---` delimiters present |
| `.instructions.md` | YAML frontmatter with valid `applyTo` glob |
| `.prompt.md` | YAML frontmatter with `name` and `description` |
| `hooks.json` | Valid JSON, `version: 1` present |
| `.sh` scripts | Proper shebang (`#!/usr/bin/env bash`), `set -euo pipefail` |
| `.ps1` scripts | Proper PowerShell structure |
| `SKILL.md` | YAML frontmatter with `name` and `description` |

### 3. Check Cross-References

- Every agent name referenced in `agents:`, `handoffs:`, or prose exists as a real `.agent.md` file
- Every file path mentioned in instructions or prompts exists
- Every tool name in `tools:` arrays is valid
- Every glob pattern in `applyTo:` matches intended files

### 4. Detect Placeholders

Search your output for these red flags — ALL must be resolved:

- `TODO`, `TBD`, `FIXME`, `XXX`
- `[placeholder]`, `[description]`, `[your-*]`
- `...` used as content placeholder
- Template variables like `{{variable}}` left unfilled
- Generic content: "be helpful", "handle appropriately", "follow best practices"

### 5. Verify Completeness

- [ ] Every requested deliverable exists
- [ ] No sections are empty or stub-only
- [ ] Examples use real, project-specific content (not toy examples)
- [ ] Error handling guidance is present where applicable

## Completion Quality Gate

Before reporting COMPLETE, ALL of these must be true:

- [ ] Every requested file exists and is readable
- [ ] YAML/JSON syntax is valid in all files
- [ ] No placeholder content remains
- [ ] Cross-references resolve to real files/agents/tools
- [ ] Content follows the project's instruction files
- [ ] Self-review completed with no blocking issues found

## Agent Configuration Feedback

If anything in your own agent definition (`.agent.md`), instructions, hooks, or prompts made this task harder or unclear, include feedback:

```markdown
#### Agent Configuration Feedback
- **Issue**: [What was unclear, missing, or incorrect in my agent config]
- **Impact**: [How it affected this task]
- **Suggestion**: [Specific improvement to consider]
- **Priority**: HIGH | MEDIUM | LOW
```

Only report feedback that is:
- **Token-efficient** — small change, high value
- **Recurring** — likely to affect future tasks
- **Specific** — actionable without further clarification
