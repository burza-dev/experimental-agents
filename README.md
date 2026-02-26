# Agent Instructions

Portable coding agent instructions for **Python 3.13+, async Django 6.x+, and C/C++ (C23/C++23)** projects. Provides deployment templates for GitHub Copilot/Agent configurations with a TDD-driven multi-agent workflow.

## Overview

This repository provides **deployment templates** - reusable GitHub Copilot/Agent configurations that can be deployed to Python, async Django, and C/C++ projects. The templates are designed to be portable and customizable for your specific project needs.

### What the Templates Provide

- Test-Driven Development (TDD) workflow
- Quality gates (coverage, linting, type checking)
- Multi-agent collaboration patterns
- Consistent coding standards

### Platform Support

| Platform | Status |
|----------|--------|
| GitHub Copilot Chat | **Supported** |
| VS Code Copilot Agents | **Supported** |
| OpenAI Codex CLI | Planned |
| Anthropic Claude Code | Planned |

## Repository Structure

- **`deployment/.github/`** - Deployment templates with placeholders (the main deliverable)
- **`.github/`** - Internal instructions for this repository (documentation-focused agents)

## What's Included

### Agents (11)

| Agent | Purpose |
|-------|---------|
| `architect` | Create acceptance criteria and test-first plans |
| `code-reviewer` | Review implementation quality |
| `coverage-test-writer` | Write tests to close coverage gaps |
| `e2e-specialist` | Implement Playwright end-to-end tests |
| `implementer` | Implement changes to pass tests |
| `manager` | Orchestrate workflow, validate completion |
| `researcher` | Search codebase and web for information |
| `tdd-test-writer` | Write failing tests before implementation |
| `test-reviewer` | Review test quality and coverage |
| `test-specialist` | General-purpose testing |
| `ux-reviewer` | Review UX/accessibility |

### Instructions (13)

| File | Applies To |
|------|------------|
| `c.instructions.md` | `**/*.c,**/*.h` |
| `cmake.instructions.md` | `**/CMakeLists.txt,**/*.cmake` |
| `config.instructions.md` | `**/*.{yaml,yml,toml}` |
| `cpp.instructions.md` | `**/*.cpp,**/*.hpp,**/*.cc,**/*.hh` |
| `docker.instructions.md` | `**/Dockerfile,**/docker-compose*.yml` |
| `documentation.instructions.md` | `**/docs/**/*.md,README.md` |
| `html.instructions.md` | `**/*.html` |
| `javascript.instructions.md` | `**/*.js` |
| `makefile.instructions.md` | `**/Makefile,**/makefile,**/*.mk` |
| `playwright.instructions.md` | `**/e2e/**/*.py` |
| `python.instructions.md` | `**/*.py` |
| `shell.instructions.md` | `**/*.{sh,bash}` |
| `tests.instructions.md` | `**/test_*.py` |

### Skills (19)

Domain-specific knowledge modules:

- API Design Patterns
- C++ Core Guidelines
- Clang-Tidy Static Analysis
- Django Async Safety
- Django Migrations
- Docstring Coverage
- Error Handling Patterns
- GoogleTest Patterns
- HTMX Patterns
- Logging Standards
- Memory Safety (Sanitizers)
- Modern CMake Patterns
- MyPy Strict Typing
- Playwright E2E Screenshots
- Pydantic Conventions
- Pytest Coverage Gates
- Release (Wheel & Docker)
- Security Patterns
- Typer CLI Testing

### Prompts (4)

| Prompt | Use Case |
|--------|----------|
| `add-feature.prompt.md` | Add new feature with TDD |
| `fix-bug.prompt.md` | Fix bug with TDD |
| `new-endpoint.prompt.md` | Create new API endpoint |
| `new-model.prompt.md` | Create new Django model |

## Deployment Guide

### Quick Start

1. **Copy deployment templates to your project:**
   ```bash
   cp -r deployment/.github/* YOUR_PROJECT/.github/
   ```

2. **Replace placeholders with your project values:**
   ```bash
   cd YOUR_PROJECT/.github

   # Define your project values
   PROJECT_NAME="myapp"              # lowercase, snake_case
   PROJECT_NAME_PASCAL="MyApp"       # PascalCase
   PROJECT_PREFIX="MYAPP"            # UPPER_SNAKE for env vars
   DEFAULT_MODEL="gpt-4o"            # Default AI model
   
   # Replace placeholders
   find . -type f -name "*.md" -exec sed -i \
     -e "s/{project_name}/$PROJECT_NAME/g" \
     -e "s/{ProjectName}/$PROJECT_NAME_PASCAL/g" \
     -e "s/{PROJECT_PREFIX}/$PROJECT_PREFIX/g" \
     -e "s/{ProjectError}/${PROJECT_NAME_PASCAL}Error/g" \
     -e "s/{ProjectSettings}/${PROJECT_NAME_PASCAL}Settings/g" \
     -e "s/{project_package}/$PROJECT_NAME/g" \
     -e "s/{DEFAULT_MODEL}/$DEFAULT_MODEL/g" \
     {} \;
   ```

3. **Review and customize** the instructions for your specific needs.

### Placeholder Reference

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{project_name}` | Project name (lowercase) | `myapp` |
| `{ProjectName}` | Project name (PascalCase) | `MyApp` |
| `{PROJECT_PREFIX}` | Env var prefix (UPPER) | `MYAPP` |
| `{ProjectError}` | Base exception class | `MyAppError` |
| `{ProjectSettings}` | Settings class name | `MyAppSettings` |
| `{project_package}` | Python package path | `myapp` |
| `{DEFAULT_MODEL}` | Default AI model name | `gpt-4o` |

### Manual Customization

After placeholder substitution, review and customize:

1. **`copilot-instructions.md`** - Update project description, tech stack, quality gates
2. **Agent files** - Adjust workflow rules for your team's process
3. **Skills** - Remove skills for technologies you don't use
4. **Quality gates** - Adjust coverage thresholds if needed (default: 75%)

## Target Projects

These instructions are designed for:

- **Python 3.13+** projects
- **Async Django 6.x+** applications
- **C23/C++23** projects
- **CMake 3.28+** build systems
- **ASGI** deployments
- Projects using **pytest**, **mypy**, **ruff**
- Projects using **GoogleTest**, **clang-tidy**, **clang-format**
- Projects with **Playwright** E2E tests
- **Bootstrap 5.x+** for frontend styling

## Future Plans

- OpenAI Codex (CLI) support
- Anthropic Claude Code support
- Additional technology stacks

## Internal Development

The `.github/` directory contains instructions specific to developing THIS repository. They are simplified for documentation/configuration work and should not be deployed to other projects.

## License

MIT License