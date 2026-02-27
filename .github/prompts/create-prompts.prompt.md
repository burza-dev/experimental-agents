---
name: create-prompts
description: Create reusable prompt files for common project workflows
---

# Create Reusable Prompts

Create prompt files for common development tasks.

## Input Variables (User-Provided)

- **Target Project**: {{target_project}}
- **Prompt Name**: {{prompt_name}}
- **Prompt Purpose**: {{prompt_purpose}}

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{target_project}}` | Yes | path | Absolute path to the target project directory |
| `{{prompt_name}}` | Yes | lowercase-hyphenated | Filename for the prompt (e.g., "add-feature" → `add-feature.prompt.md`) |
| `{{prompt_purpose}}` | Yes | string | What the prompt helps accomplish (e.g., "Add a new API endpoint") |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## Common Prompt Types

### Development
- `add-feature` - Add new functionality
- `fix-bug` - Debug and fix issues
- `refactor` - Improve code structure
- `add-tests` - Write test coverage

### Review
- `review-pr` - Review pull request
- `review-security` - Security-focused review
- `review-performance` - Performance analysis

### Documentation
- `document-api` - Generate API docs
- `update-readme` - Update README

## Workflow

1. Identify common repetitive task
2. Define variables for user inputs
3. Structure clear workflow steps
4. Add constraints and quality gates
5. Define expected deliverables
6. **Self-review** - Verify the prompt file against all quality criteria before finalizing

## Deliverable

Create `.github/prompts/{{prompt_name}}.prompt.md` with the structure shown below.

## Output File Template

The generated prompt file should contain (template variables shown with `<angle_brackets>` to distinguish from the prompt's own `{{double_braces}}` variables):

```yaml
---
name: <prompt_name>
description: <one-line description>
---
```

```markdown
# <Title>

## Context
<context_variable>

## Variables
| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `<var1>` | Yes/No | type | Description |
| `<var2>` | Yes/No | type | Description |

## Requirements
- Requirement 1
- Requirement 2

## Workflow
1. Step 1
2. Step 2
3. Step 3

## Error Handling
- If X fails: Do Y
- If Y fails: Do Z

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Deliverables
- [ ] Deliverable 1
- [ ] Deliverable 2
```

**Key:** Variables in the OUTPUT file should use `{{double_braces}}`. The `<angle_brackets>` above are placeholders for you to fill in when creating the actual prompt.

## Error Handling

- If prompt name conflicts with existing prompt: List conflict and suggest alternative name
- If purpose is too vague: Ask for specific use case before proceeding
- If YAML frontmatter is invalid: Fix syntax and re-validate
- If prompt has no clear workflow: Request step-by-step breakdown from user

## Success Criteria

- [ ] Prompt file created with valid YAML frontmatter
- [ ] `name` matches the filename (without extension)
- [ ] `description` is clear and under 200 characters
- [ ] All template variables are documented in Variables section
- [ ] Workflow has numbered, actionable steps
- [ ] Success Criteria section with checkable items
- [ ] Error Handling section included

## Quality Checklist

- [ ] `name` is unique and descriptive
- [ ] `description` is clear
- [ ] All variables are documented
- [ ] Steps are actionable
- [ ] Deliverables are specified
- [ ] Quality constraints included
