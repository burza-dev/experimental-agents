# Copilot Instructions for {ProjectName}

## Project Overview

{ProjectName} is a Python 3.13+ async server application using Django for web functionality with a Bootstrap frontend. Update this description to match your project.

## Multi-Agent Workflow

This project uses specialized agents for TDD-driven development.

### Available Agents

| Agent | Purpose |
|-------|---------|
| `manager` | Orchestrates workflow, validates completion (no execution) |
| `architect` | Plans tests, identifies async hazards |
| `researcher` | Analyzes project structure, tech stack, and conventions |
| `test-specialist` | General-purpose test fallback (when TDD split doesn't apply) |
| `tdd-test-writer` | Writes failing tests first in TDD red phase |
| `coverage-test-writer` | Writes additional tests after implementation to fill coverage gaps |
| `e2e-specialist` | Writes Playwright browser tests |
| `implementer` | Implements code to pass tests |
| `code-reviewer` | Reviews code quality (no diffs) |
| `test-reviewer` | Reviews test quality (no diffs) |
| `ux-reviewer` | Reviews UI/accessibility (no diffs) |
| `manual-tester` | Validates features through manual testing — acceptance criteria, user flows, edge cases |

### TDD Sequence

1. **Plan** → Architect creates test plan with acceptance criteria
2. **Test** → TDD Test Writer writes failing tests first
3. **Implement** → Implementer writes code to pass tests
4. **Coverage** → Coverage Test Writer closes coverage gaps after implementation
5. **Iterate** → Repeat test/implement until quality gates pass
6. **Review** → Reviewers provide feedback (no diffs)
7. **Fix & Re-review** → If issues found, Implementer fixes → Reviewers re-review (loop until approved, max 3 cycles)
8. **Manual Test** → Manual Tester verifies acceptance criteria, user flows, and edge cases
9. **Validate** → Manager confirms all gates pass

### Agent Instructions

- Agents are defined in `.github/agents/`
- Skills are defined in `.github/skills/`
- Path-specific instructions in `.github/instructions/`

## Critical Rules - Read First

**NEVER** finish a task early or leave work incomplete. You **MUST**:

1. **Complete every requirement** specified in the task before marking it done
2. **Implement all code** - no mockups, stubs, placeholders, or TODO comments unless explicitly allowed
3. **Write comprehensive tests** - 75% code and branch coverage required; integration tests including full end-to-end required; untestable code must be refactored
4. **Ignore time limits** - quality trumps speed; take as long as needed to deliver production-ready code
5. **Verify your work** - run all tests, linters, and type checkers before finishing
6. **Fix all issues** - do not leave known bugs, warnings, or failing test
7. **Listen to user request** - user requests must be addressed, even if they seem to be out of the task scope
8. **Always excel at your jobs** - when you think that you've approached end of your task analyse original prompt and your job again to determine if everything was implemented as good as possible in context of the whole repository. If there are any possible improvements or missing points then implement them before finishing. Every change should be complete and bring value to the repository
9. **Refactor and reuse** - always avoid adding new code, when encountering similar functions refactor and reduce amount of code without reducing functionality, you must focus on providing value to the project while keeping codebase small and maintainable

## Code Quality Standards

### Python Code (Mandatory)

All Python code **MUST** pass these quality gates with zero violations:

```bash
# Linting and formatting (zero violations)
uv run ruff check . && uv run ruff format --check .

# Type checking (strict mode, zero errors)
uv run mypy --strict .

# Tests (75% statement + branch coverage, tracked separately for unit/integration)
uv run pytest --cov --cov-branch --cov-fail-under=75

# Docstring coverage (100% for source code)
uv run interrogate src/ -v --fail-under=100

# Cyclomatic complexity
# Source code: CC ≤ 5 (grade A) - strict
uv run radon cc src/ -a -nb --total-average
# Test code: CC ≤ 10 (grade B) - relaxed
uv run radon cc tests/ -a -nc --total-average

# Maintainability index
# Source code: MI ≥ 20 (grade A) - strict
uv run radon mi src/ -nb
# Test code: MI ≥ 10 (grade B) - relaxed
uv run radon mi tests/ -nc
```

### Code Style

- Follow PEP 8 and PEP 257 for docstrings
- Use type hints for ALL functions, methods, and class attributes
- Maximum line length: 100 characters
- Use descriptive variable and function names
- Keep functions small and focused (single responsibility)
- Avoid nested conditionals deeper than 3 levels

### Frontend Code (When Applicable)

- Use Bootstrap 5.x+ for styling (no custom CSS unless absolutely necessary)
- Use semantic HTML5 elements
- Ensure accessibility (ARIA labels, proper headings, etc.)
- ESLint: zero warnings on JavaScript files
- Valid, well-formed HTML

### Pytest-Asyncio Configuration

All async tests use `pytest-asyncio` with auto mode. Add to `pyproject.toml`:

```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "function"
```

With `asyncio_mode = "auto"`, async test functions are collected automatically
without requiring the `@pytest.mark.asyncio` decorator.

### Testing Requirements

**75% coverage minimum required.** Tests must:

- Cover all code paths (statements AND branches)
- Test edge cases and error conditions
- Use realistic mocks for external dependencies
- Be deterministic (no flaky tests)
- Have clear, descriptive names
- Coverage tracked separately for unit and integration test suites

**Allowed exclusions:**
- Abstract methods and `@abstractmethod` decorated functions
- `TYPE_CHECKING` blocks (import-only code)

**Forbidden without explicit permission:**
- `# pragma: no cover` (except for abstract methods/TYPE_CHECKING)
- `# type: ignore`
- Skipping tests with `@pytest.mark.skip`

### Documentation

- All public functions/methods must have docstrings
- Complex logic must have inline comments
- Update README.md when adding new features
- Keep documentation in sync with code
- Documentation is automatically generated and published after every merge to main branch

## Technology Stack

### Core

- **Python 3.13+** with async/await
- **Django 6.x+** (async) for all web functionality
- **SQLite** for state storage (via aiosqlite)
- **Pydantic 2.x+** for data validation and settings

### CLI

- **Typer** for command-line interface
- **Rich** for terminal output formatting

### Quality Tools

- **Ruff** for linting and formatting
- **mypy** for static type checking (strict mode)
- **pytest** with pytest-cov for testing
- **radon** for complexity metrics

### Frontend

- **Bootstrap 5.x+** for UI components
- **Django Templates** for server-side rendering
- **HTMX** (optional) for dynamic updates

## Async Django Rules (Mandatory)

### Priority Order (use first available option)
1. **Native async Django** - PREFERRED (async views, async ORM methods like `aget()`, `aexists()`, `acount()`)
2. **Async libraries** - use `httpx`, `aiofiles`, `aiosqlite` instead of sync equivalents
3. **Creative async solutions** - find async patterns for common operations
4. **`sync_to_async` wrapper** - LAST RESORT only when no async alternative exists

### Absolutely Required
- ALL views must be async unless they have no I/O operations
- Use async ORM methods: `aget()`, `aexists()`, `acount()`, `aiterator()`
- Use `async for` for QuerySet iteration
- Use `httpx.AsyncClient` instead of `requests`
- Use `aiofiles` for file operations
- Test all async code paths

### Forbidden (without explicit approval)
- Sync views with `sync_to_async` for simple cases that could be native async
- Using `requests` library (use `httpx`)
- Sync file I/O (use `aiofiles`)
- Blocking operations in async contexts
- `sync_to_async` when native async ORM method exists

## ASGI Configuration

This is an async Django project served via ASGI.

### asgi.py Setup

The `{project_package}/asgi.py` module exposes the ASGI application:

```python
import os

from django.core.asgi import get_asgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "{project_package}.settings")

application = get_asgi_application()
```

### Running the ASGI Server

**Uvicorn** (recommended):

```bash
uvicorn {project_package}.asgi:application --reload
```

**Daphne** (alternative — required for Django Channels / WebSockets):

```bash
daphne {project_package}.asgi:application
```

### ASGI Middleware Considerations

- Place ASGI middleware **before** `get_asgi_application()` in `asgi.py`
- Django's `SecurityMiddleware`, `SessionMiddleware`, and `AuthenticationMiddleware`
  remain in `MIDDLEWARE` settings (they run inside the Django ASGI handler)
- For custom ASGI-level middleware (e.g., Sentry, request-id propagation), wrap
  the `application` object directly in `asgi.py`
- When using Django Channels, replace `get_asgi_application()` with a
  `ProtocolTypeRouter` that delegates HTTP and WebSocket protocols

## Project Structure

```
{project_name}/
├── src/{project_package}/          # Main Python package
│   ├── __init__.py
│   ├── __version__.py
│   ├── core/             # Core orchestrator logic
│   ├── agents/           # AI agent adapters
│   ├── config/           # Configuration management
│   ├── models/           # Data models
│   ├── cli/              # CLI commands
│   └── web/              # Django web application
│       ├── templates/    # Django/Bootstrap templates
│       └── static/       # Static assets
├── tests/                # Test suite (mirrors src structure)
│   ├── unit/
│   ├── integration/
│   ├── e2e/
│   └── fixtures/
├── docs/                 # Documentation
├── tasks/                # Implementation task files
└── scripts/              # Utility scripts
```

## Workflow Guidelines

### Before Writing Code

1. Read the full task description and requirements
2. Read project documentation related to the task
3. Understand the existing codebase and patterns
4. Plan your approach before coding
5. Check for existing utilities you can reuse

### While Coding

1. Write tests alongside or before implementation (TDD encouraged)
2. Check project documentation for similar implementations you can reuse
3. Run quality checks frequently during development
4. Keep commits atomic and well-described
5. Follow existing code patterns and conventions

### Before Completing a Task

Run this complete verification:

```bash
# Install dependencies
uv sync

# Format and lint
uv run ruff format .
uv run ruff check . --fix

# Type check
uv run mypy --strict src/

# Run tests with coverage (75% minimum)
uv run pytest --cov --cov-branch --cov-fail-under=75 --cov-report=term-missing

# Docstring coverage (100% for source code)
uv run interrogate src/ -v --fail-under=100

# Check complexity
uv run radon cc src/ -a -nb --total-average
uv run radon cc tests/ -a -nc --total-average
uv run radon mi src/ -nb
uv run radon mi tests/ -nc

```

**Do NOT mark a task complete until ALL checks pass.**

## Prohibited Practices

**NEVER do any of these:**

1. **Avoid to do part of the task because it's hard or complex to do**
2. **Tell user that his request is out of scope of current change**
3. Leave incomplete implementations with TODO/FIXME comments
4. Use `# type: ignore` without a specific error code and justification
5. Use `# pragma: no cover` to skip untestable code
6. Write tests that only cover happy paths
7. Skip writing tests "to save time"
8. Use `Any` type when a specific type is possible
9. Catch generic `Exception` without re-raising or specific handling
10. Leave debug print statements in code
11. Hardcode credentials or secrets
12. Create workarounds instead of proper solutions

## Agent Behavior

When working on tasks:

1. **Be thorough** - implement every detail, not just the main functionality
2. **Be critical** - review your own code for issues before finishing
3. **Be persistent** - keep working until ALL requirements are met
4. **Be honest** - if you cannot complete something, explain why clearly

**Remember: A task is NOT complete until:**
- All code is written and functional
- All tests pass with ≥75% coverage (unit and integration tracked separately)
- All quality gates pass (ruff, mypy, radon)
- Documentation is updated
- The task file is marked as complete

## References

- [Python Style Guide (PEP 8)](https://peps.python.org/pep-0008/)
- [Django Documentation](https://docs.djangoproject.com/)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [Typer Documentation](https://typer.tiangolo.com/)
- [Bootstrap 5 Documentation](https://getbootstrap.com/docs/5.3/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [mypy Documentation](https://mypy.readthedocs.io/)
