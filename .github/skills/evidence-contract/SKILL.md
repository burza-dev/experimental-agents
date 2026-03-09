---
name: evidence-contract
description: Structured communication protocol for orchestrator-subagent workflows. Use when delegating work to subagents, reporting task completion to an orchestrator, or designing multi-agent handoff patterns. Defines mandatory response sections, delegation templates, and review outcome handling.
---

# Evidence Contract

Standardized protocol for communication between orchestrator agents and subagents. Both sides MUST follow this contract.

## Subagent Response Format (MANDATORY)

Every subagent MUST report using this EXACT structure. Omitting any section causes the orchestrator to reject the response.

```markdown
## Completion Report

### Status
COMPLETE | PARTIAL | BLOCKED

### Task Received
[1-2 sentence summary of what was delegated to you]

### Actions Taken
1. [Specific action with file path or search query]
2. [Next action...]
3. [...]

### Files Changed
| File | Action | Description |
|------|--------|-------------|
| path/to/file.md | created | Agent definition for test-writer role |
| path/to/other.md | modified | Added error handling section |

### Key Decisions Made
- [Decision]: [Rationale] (e.g., "Used pytest over unittest: project already has pytest fixtures")
- [Decision]: [Rationale]

### Output Summary
[2-5 sentences describing the deliverable. Include specific details:
counts, names, patterns used. NOT just "created the file".]

### Blockers (if PARTIAL or BLOCKED)
| Blocker | Attempted Resolution | Needs |
|---------|---------------------|-------|
| [What blocked] | [What you tried] | [What you need to proceed] |

### Suggestions
- [Specific, actionable improvement for future work]
```

### Response Quality Rules

1. **Be specific, not generic** — "Created 3 instruction files for Python, TypeScript, and Markdown" not "Created instruction files"
2. **Include file paths** — Every file mentioned must have its full path
3. **Explain decisions** — If you chose between alternatives, say why
4. **Quantify work** — How many files, how many sections, how many checks
5. **No diffs or code blocks** — Reports are summaries, not code reviews. Never paste file contents.
6. **No vague status** — COMPLETE means 100% done. PARTIAL means specific items remain. BLOCKED means specific items cannot proceed.

## Orchestrator Delegation Format (MANDATORY)

When delegating work, the orchestrator MUST provide ALL of these sections:

```markdown
## Delegation: [Task Name]

### Context
- **User's Original Request**: [Full user request, not paraphrased]
- **Current Phase**: [Phase name] (Phase N of M)
- **Previous Phase Output**: [Key findings/decisions from prior phases, or "None — first phase"]
- **Target Project**: [Path or identifier]

### Task Requirements
1. [Specific deliverable 1]
2. [Specific deliverable 2]
3. [...]

### Constraints
- [Constraint 1: e.g., "Files must go in {{project_path}}/.github/agents/"]
- [Constraint 2: e.g., "Use only these tools: read, edit, search"]

### Acceptance Criteria
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]

### Response Requirements
Respond using the Evidence Contract format. Your response MUST include:
- Status (COMPLETE/PARTIAL/BLOCKED)
- All files changed with paths
- Key decisions with rationale
- Specific output summary (not generic)
```

### Delegation Quality Rules

1. **Pass full user context** — Subagents cannot read the orchestrator's mind. Include the original request.
2. **Reference prior work** — If a researcher already analyzed the project, summarize key findings for the developer.
3. **Be explicit about deliverables** — "Create 3 agent files" not "Create agents as needed".
4. **Set measurable acceptance criteria** — "Description under 200 chars" not "Good description".
5. **Never delegate without file paths** — If you want files created, specify exactly where.

## Review Outcome Handling

### For Reviewers

Reviewers MUST use this verdict format:

```markdown
## Review Verdict

### Status: APPROVED | CHANGES REQUIRED | NEEDS DISCUSSION

### Files Reviewed
| File | Verdict | Issues |
|------|---------|--------|
| path/to/file.md | APPROVED | None |
| path/to/other.md | CHANGES REQUIRED | 2 blocking, 1 should-fix |

### Blocking Issues (must fix before approval)
1. [File]: [Issue] → [Required fix]
2. [File]: [Issue] → [Required fix]

### Should-Fix Issues (fix recommended)
1. [File]: [Issue] → [Suggested fix]

### Improvements (optional enhancements)
1. [Suggestion]
```

### For Orchestrators Handling Reviews

| Verdict | Action |
|---------|--------|
| APPROVED | Proceed to next phase. Collect suggestions. |
| CHANGES REQUIRED | Re-delegate to developer WITH the reviewer's specific findings. After fix, re-delegate to SAME reviewer. Max 3 cycles. |
| NEEDS DISCUSSION | Analyze the concern, make a decision, instruct developer. Then re-review. |

## Anti-Patterns

### Subagent Anti-Patterns
- ❌ "I created the files" — WHERE? WHAT files? HOW MANY?
- ❌ Returning file contents instead of summaries
- ❌ "COMPLETE" status when items are skipped
- ❌ Omitting the Suggestions section
- ❌ Generic summaries that could apply to any task

### Orchestrator Anti-Patterns
- ❌ "Create the agent definitions" — WHICH agents? WHERE? WHAT requirements?
- ❌ Delegating without sharing researcher findings
- ❌ Not passing the user's original request
- ❌ Accepting COMPLETE without reviewer confirmation
- ❌ Skipping re-review after developer fixes
