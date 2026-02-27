---
applyTo: "**/*.prompt.md"
---

# Prompt File Rules

## File Structure

Prompt files MUST have:
1. YAML frontmatter (with recommended name and description)
2. Markdown body with prompt content

```markdown
---
name: prompt-name
description: Brief description of what the prompt does
---

# Prompt Title

Instructions with {{variable}} placeholders...
```

## YAML Frontmatter Requirements

### Recommended Properties
- `name` - Unique identifier, lowercase with hyphens (defaults to filename if omitted)
- `description` - Brief explanation of prompt's purpose (defaults to filename if omitted)

### Optional Properties
- `agent` - Agent/mode for prompt execution (e.g., `"ask"`, `"agent"`, `"plan"`, or custom agent name)
- `tools` - Array of tools available during prompt execution
- `model` - Specific model to use (e.g., `"gpt-4"`, `"claude-sonnet"`)
- `argument-hint` - Hint text shown in chat input field

## Variable Syntax

### VS Code Variable Syntax (processed by the prompt system)

These variables are recognized and processed by VS Code when running prompts:

- `${input:variableName}` — prompts user for input
- `${input:variableName:placeholder}` — with placeholder text
- `${selection}` — current editor selection
- `${file}` — current file path
- `${workspaceFolder}` — workspace root

```markdown
## Task
Create a ${input:componentType} named ${input:componentName:MyComponent}.

Use the code in ${selection} as a starting point.
Project root: ${workspaceFolder}
```

### Template Variable Syntax (NOT processed by VS Code)

Use `{{variable_name}}` as conceptual placeholders in documentation or templates
that are meant to be filled in manually. VS Code does **not** prompt for these.

```markdown
## Variables
- {{component_type}}: Type of component (e.g., "form", "modal")
- {{component_name}}: Name for the component
```

## Naming Conventions

- **File name**: `prompt-name.prompt.md` (lowercase, hyphens)
- **Prompt name**: Same as filename without extension

Examples:
- ✅ `create-api-endpoint.prompt.md`
- ✅ `review-pull-request.prompt.md`
- ❌ `DoTask.prompt.md` (no PascalCase)
- ❌ `my prompt.prompt.md` (no spaces)

## Content Structure

### Recommended Sections
1. Task description
2. Variables with descriptions
3. Requirements/constraints
4. Workflow steps
5. Expected deliverables

### Example Structure

```markdown
---
name: add-feature
description: Add a new feature to the codebase
---

# Add Feature

## Context
{{context}}

## Requirements
- Feature name: {{feature_name}}
- Scope: {{scope}}

## Constraints
- Must include tests
- Must follow existing patterns

## Workflow
1. Analyze existing similar features
2. Create implementation
3. Write tests
4. Update documentation

## Deliverables
- [ ] Feature implementation
- [ ] Unit tests
- [ ] Documentation update
```

## Forbidden Patterns

- Missing variable definitions
- Variables without descriptions
- Vague or ambiguous instructions
- Prompts without clear deliverables

## Quality Standards

- All variables must be documented
- Steps must be clear and actionable
- Expected outputs must be specified
- Constraints/quality gates included
- File content must be under 30,000 characters
