---
name: create-instructions
description: Create path-specific instruction files for a project's file types
---

# Create Path-Specific Instructions

Create instruction files for specific file types or patterns.

## Target
- **File Type**: {{file_type}}
- **Glob Pattern**: {{glob_pattern}}
- **Target Project**: {{target_project}}
- **Instruction Name**: {{instruction_name}}
- **Code Language**: {{language}}

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{file_type}}` | Yes | string | Human-readable name for the file type (e.g., "TypeScript", "Python Tests") |
| `{{glob_pattern}}` | Yes | glob | Pattern to match files (e.g., `**/*.ts`, `**/test_*.py`) |
| `{{target_project}}` | Yes | path | Absolute path to the target project directory |
| `{{instruction_name}}` | Yes | lowercase-hyphenated | Filename for instructions (e.g., "typescript" → `typescript.instructions.md`) |
| `{{language}}` | Yes | string | Language identifier for code blocks (e.g., `typescript`, `python`, `java`) |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## Requirements

### Content to Include
- Formatting rules
- Naming conventions
- Code patterns (good vs bad examples)
- Framework-specific guidelines
- Forbidden patterns

### Examples
Provide clear examples of:
- ✅ Good patterns to follow
- ❌ Bad patterns to avoid

## Workflow

1. Identify conventions for the file type
2. Analyze existing files in the project for patterns
3. Define glob pattern that matches target files accurately
4. Write clear, specific instructions
5. Include good and bad examples
6. List forbidden patterns
7. **Self-review** - Verify glob pattern accuracy, example quality, and no overlap with existing instructions

## Deliverable

Create `.github/instructions/{{instruction_name}}.instructions.md` with:
- Valid YAML frontmatter with `applyTo` pattern
- Clear instructions relevant to matched files
- Code examples with syntax highlighting
- Forbidden patterns section

## File Structure Template

The generated file should follow this structure (use actual code fences when creating):

```text
---
applyTo: "{{glob_pattern}}"
---

# {{file_type}} Rules

## Formatting
Rules for formatting these files.

## Good Patterns
(fenced code block with {{language}} identifier)
// Example of good code

## Bad Patterns
(fenced code block with {{language}} identifier)
// Example of bad code

## Forbidden
- Pattern 1
- Pattern 2
```

**Note:** Replace "(fenced code block with {{language}} identifier)" with actual triple-backtick code fences using the appropriate language.

## Error Handling

- If glob pattern matches no files: Warn and ask for confirmation or adjusted pattern
- If glob pattern overlaps with existing instructions: List conflicts and recommend resolution
- If file type has no clear conventions: Ask for explicit style guide or use project's existing patterns
- If YAML frontmatter is invalid: Fix syntax before completing

## Success Criteria

- [ ] Instructions file created with valid YAML frontmatter
- [ ] `applyTo` glob pattern matches intended files only
- [ ] At least 2 good pattern examples included
- [ ] At least 2 bad pattern examples included
- [ ] Forbidden patterns section with specific items
- [ ] No overlap with other instruction files
- [ ] Code blocks use correct language identifier

## Quality Checklist

- [ ] `applyTo` pattern matches intended files
- [ ] Instructions are specific to file type
- [ ] Good/bad examples included
- [ ] Forbidden patterns listed
- [ ] No overlap with other instruction files
