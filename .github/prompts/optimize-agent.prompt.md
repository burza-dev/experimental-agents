---
name: optimize-agent
description: Improve an existing agent's effectiveness, clarity, and performance
---

# Optimize Agent

Analyze and improve an existing agent definition.

## Target Agent
{{agent_path}}

## Optimization Goals
{{optimization_goals}}

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{agent_path}}` | Yes | path | Path to the agent definition file to optimize |
| `{{optimization_goals}}` | No | string | Specific improvements desired (e.g., "reduce tool count", "improve clarity", "add error handling"); if omitted, perform general optimization |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## Optimization Areas

### 1. Description Quality
- Is description specific and action-oriented? 
- Does it fit in 200 characters while conveying purpose?
- Does it differentiate this agent from others?

### 2. Tool Minimization
For each tool, ask:
- Is this tool actually used in the instructions?
- Could the agent function without it?
- Is there a more appropriate tool?

| Principle | Example |
|-----------|---------|
| Least privilege | Remove `edit` from analysis-only agents |
| Specificity | Use `search` instead of broad `codebase` if only searching |
| Security | Reconsider `execute` if not strictly needed |

### 3. Instruction Clarity
- Replace vague instructions with specific ones
- Add concrete examples where helpful
- Define scope boundaries explicitly
- Include error recovery guidance

### 4. Workflow Efficiency
- Can steps be parallelized or reordered?
- Are there redundant instructions?
- Is the completion criteria clear?

### 5. Cross-Agent Integration
- Does this agent properly hand off to others?
- Are handoff prompts sufficiently detailed?
- Is there unnecessary overlap with other agents?

### 6. Self-Review Mechanism
- Does the agent include a self-review step before reporting completion?
- Are there quality gate checklists in the agent's workflow?
- Does the agent verify its own output against success criteria?

### 7. File Management Capabilities
- If the agent creates or modifies files, does it have the `execute` tool for running builds/tests/lints?
- If the agent is a developer role, can it verify its changes via terminal commands?
- Are file-related tools (`edit`, `read`, `search`) appropriately configured?

## Optimization Workflow

1. **Read current agent** - Understand current state
2. **Identify issues** - Using the checklist below
3. **Propose improvements** - Document each change
4. **Apply changes** - Modify the agent file
5. **Verify quality** - Ensure no regressions
6. **Self-review** — Verify optimized agent against all quality checklist items before finalizing

## Quality Checklist

Before:
- [ ] Current description length: <count> chars
- [ ] Current tools: [list]
- [ ] Has error handling: yes/no
- [ ] Has completion format: yes/no

After:
- [ ] New description length: <count> chars (should be ≤200)
- [ ] New tools: [list] (should be fewer or same)
- [ ] Has error handling: yes
- [ ] Has completion format: yes
- [ ] Instructions more specific: yes

## Error Handling

- If agent file doesn't exist: Report error and suggest creation prompt
- If agent is already optimal: Report findings and confirm no changes needed
- If optimization conflicts with other agents: Flag overlap and suggest resolution

## Success Criteria

- [ ] All optimization areas reviewed
- [ ] At least one meaningful improvement made (unless already optimal)
- [ ] No functionality removed without replacement
- [ ] Agent still passes all reviewer checks
- [ ] Changes documented with rationale

## Deliverables

- [ ] Optimized agent definition file
- [ ] Summary of changes made
- [ ] Before/after comparison
- [ ] Any remaining improvement opportunities noted
