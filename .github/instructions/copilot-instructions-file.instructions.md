---
applyTo: "**/copilot-instructions.md"
---

# Copilot Instructions File Rules

## File Location

Repository-wide copilot instructions go in:
```
.github/copilot-instructions.md
```

## Content Structure

```markdown
# Copilot Instructions for [Project Name]

## Project Overview
Brief description of what the project does.

## Repository Structure
Key directories and their purposes.

## Tech Stack
Languages, frameworks, and tools used.

## Build & Development
Commands for building, testing, linting.

## Coding Standards
Project-specific conventions.

## Quality Gates
Required checks before merging.
```

## Required Sections

### Project Overview
Must include:
- What the project does
- Main components/modules
- Target audience or users

### Build & Development
Must include:
- Prerequisites (versions)
- Build commands
- Test commands
- Lint/format commands

## Section Guidelines

### Repository Structure
````markdown
## Repository Structure
```
src/           # Source code
tests/         # Test files
docs/          # Documentation
scripts/       # Build scripts
.github/       # GitHub config
```
````

### Tech Stack
```markdown
## Tech Stack
| Category | Technology |
|----------|------------|
| Language | Python 3.11+ |
| Framework | Django 5.x |
| Testing | pytest |
| Linting | ruff |
```

### Coding Standards
```markdown
## Coding Standards
- Use snake_case for functions and variables
- Use PascalCase for classes
- Type hints required for all public functions
- Docstrings for all public APIs
```

### Quality Gates
```markdown
## Quality Gates
All PRs must pass:
- [ ] Unit tests (coverage > 80%)
- [ ] Type checks (mypy strict)
- [ ] Lint checks (ruff, no warnings)
- [ ] Build succeeds
```

## Best Practices

### Be Specific
- ❌ "Run tests"
- ✅ "Run `pytest tests/ -v` for unit tests"

### Include Versions
- ❌ "Requires Python"
- ✅ "Requires Python >= 3.11"

### Verify Commands
Test all documented commands work before committing.

## Forbidden Patterns

- Outdated or incorrect commands
- Missing version requirements
- Generic/placeholder content
- Commands that don't work
- Structure that doesn't match actual repo

## Quality Standards

- Project description is accurate
- All commands are tested and working
- Structure reflects actual repository
- Versions match actual requirements
- No broken references
- File content must be under 30,000 characters
