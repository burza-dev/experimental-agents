---
name: create-copilot-instructions
description: Create repository-wide copilot-instructions.md for a project
---

# Create Copilot Instructions

Create a `copilot-instructions.md` file that provides repository-wide context for GitHub Copilot.

## Target Project
{{project_path}}

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{project_path}}` | Yes | path | Absolute path to the target project directory |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## What to Include

The `copilot-instructions.md` file should contain:
- [ ] Project overview (what it does, who uses it)
- [ ] Repository structure (key directories and their purposes)
- [ ] Tech stack (languages, frameworks, tools)
- [ ] Build/test/lint commands
- [ ] Coding conventions
- [ ] Common workflows

## Workflow

1. **Analyze Project Structure**
   - List top-level directories and their purposes
   - Identify source code locations
   - Find test directories
   - Locate configuration files

2. **Identify Tech Stack**
   - Check package files (`package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`)
   - Note primary languages from file extensions
   - Identify frameworks from dependencies
   - Find build tools and task runners

3. **Extract Commands**
   - Read `package.json` scripts or `Makefile` targets
   - Test each command to verify it works
   - Document prerequisites and expected output

4. **Document Conventions**
   - Examine existing code for patterns
   - Check for style guides (`CONTRIBUTING.md`, linter configs)
   - Note naming conventions
   - Document import/export patterns

5. **Create Instructions File**
   - Write concise, actionable guidance
   - Include working commands
   - Add troubleshooting tips

6. **Self-Review**
   - Verify all commands are tested and working
   - Confirm project structure is accurately documented
   - Ensure no placeholder text remains
   - Check content is under 30,000 characters

## Deliverable

Create `{{project_path}}/.github/copilot-instructions.md` with this structure:

```markdown
# Copilot Instructions for [Project Name]

## Project Overview
Brief description of what the project does.

## Repository Structure
| Directory | Purpose |
|-----------|---------|
| `src/` | Main source code |
| `tests/` | Test files |
| ... | ... |

## Tech Stack
- **Language**: [Primary language]
- **Framework**: [Main framework]
- **Build Tool**: [Build system]
- **Test Framework**: [Test runner]

## Development Commands

### Build
[command]

### Test
[command]

### Lint
[command]

## Coding Conventions
- [Convention 1]
- [Convention 2]

## Common Tasks
Brief guidance on frequent development tasks.
```

## Error Handling

- If project path does not exist: Report error and request valid path
- If no package manager found: Document available commands from Makefile, scripts, or CI
- If commands fail when tested: Document the command and note it needs verification
- If project structure is non-standard: Document what exists rather than assuming conventions

## Success Criteria

- [ ] File created at `.github/copilot-instructions.md`
- [ ] Valid markdown with proper headings
- [ ] Repository structure accurately documented
- [ ] All listed commands tested and working
- [ ] Tech stack correctly identified
- [ ] Content is under 30,000 characters
- [ ] No placeholder text remains (e.g., "[fill in]")

## Quality Checklist

- [ ] Project overview is accurate
- [ ] Repository structure is complete
- [ ] Commands are verified working
- [ ] Conventions are specific, not generic
- [ ] Content is concise and actionable
