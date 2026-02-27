---
name: review-configuration
description: Review existing GitHub Copilot agent configuration for a project
---

# Review Agent Configuration

Review and improve existing GitHub Copilot configuration.

## Target Project
{{project_path}}

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{project_path}}` | Yes | path | Absolute path to the project with existing configuration to review |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## Review Scope
- [ ] Repository-wide instructions (`copilot-instructions.md`)
- [ ] Agent definitions (`.agent.md` files)
- [ ] Path-specific instructions (`.instructions.md` files)
- [ ] Prompts (`.prompt.md` files)
- [ ] Hooks (`hooks.json` and scripts)

## Severity Level Definitions

| Severity | Definition | Action Required |
|----------|------------|-----------------|
| **Blocking** | Prevents functionality; syntax errors, missing required fields, broken references | Must fix before use |
| **Should-Fix** | Reduces effectiveness; unclear instructions, suboptimal patterns, missing sections | Fix in current review |
| **Optional** | Minor improvements; style consistency, additional examples, documentation gaps | Fix when convenient |

## Review Criteria

> **Review Stance:** Reviewers should be **critical and nitpicky**. Flag every issue found, no matter how small. A thorough review catches problems before they affect users.

### For All Files
- Valid YAML/JSON syntax
- Proper file naming
- Clear, actionable content
- No outdated information

### For Agent Definitions
- Description is specific (max 200 chars)
- Tools list is minimal but sufficient
- Instructions have clear scope
- Error handling included

### For Instructions
- Glob patterns match intended files
- Content is relevant to matched files
- Good/bad examples provided
- No overlapping patterns

### For Prompts
- All variables documented
- Steps are actionable
- Deliverables specified

### For Hooks
- `version: 1` present
- Scripts exist and are executable
- Reasonable timeouts
- Cross-platform support
- Trigger names match target environment (CLI camelCase or VS Code PascalCase)
- Input field names correct for target environment (`toolName`/`toolArgs` vs `tool_name`/`tool_input`)
- Blocking output format correct (`{blocked: true}` for CLI vs `hookSpecificOutput.permissionDecision` for VS Code)

## Workflow

1. List all configuration files
2. **Fetch latest documentation** - Use web/fetch tools to verify against current GitHub Copilot docs for accuracy
3. Review each file against criteria
4. Document issues found
5. Categorize by severity (blocking/should-fix/optional)
6. Recommend fixes
7. **Self-review** - Verify all review findings are accurate and actionable before reporting

## Output Format

```markdown
## Review Summary

### Files Reviewed
- [x] copilot-instructions.md
- [x] agents/manager.agent.md
- [ ] ...

### Issues Found

#### Blocking
| File | Issue | Fix |
|------|-------|-----|
| file.md | Description | Recommendation |

#### Should-Fix
| File | Issue | Fix |
|------|-------|-----|
| file.md | Description | Recommendation |

#### Optional
| File | Suggestion |
|------|------------|
| file.md | Improvement idea |

### Verdict
- [ ] APPROVED
- [ ] CHANGES REQUIRED
```

## Error Handling

- If configuration directory does not exist: Report missing `.github/` and list what should be created
- If files have syntax errors: Document exact error location and provide corrected syntax
- If files reference non-existent paths: List broken references with suggested corrections
- If review cannot complete: Document partial results and blocking issue

## Success Criteria

- [ ] All specified configuration files reviewed
- [ ] Each file checked against all applicable criteria
- [ ] Issues categorized by correct severity level
- [ ] Every issue has an actionable fix recommendation
- [ ] Verdict reflects review findings accurately
- [ ] No files skipped without explanation

## Quality Checklist

- [ ] All files reviewed
- [ ] Issues categorized correctly
- [ ] Fixes are actionable
- [ ] Review is thorough and accurate
