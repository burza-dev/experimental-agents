---
applyTo: "**/*.py"
---

# Python code rules

## Language version
- Use Python 3.13+ idioms and features
- Strong typing with `mypy --strict` compatibility
- No `Any` type unless absolutely necessary with justification

## Python 3.13+ Features

### Free-Threading (PEP 703)
- Python 3.13 introduces experimental no-GIL (free-threading) mode
- Build with `--disable-gil` for true parallelism
- Use `python3.13t` interpreter for free-threaded builds
- **Caution**: Many C extensions not yet compatible - test thoroughly

### Improved Error Messages
- Take advantage of enhanced error messages for debugging
- Python 3.13 provides better suggestions for typos and missing imports
- Error messages now include more context about the cause

### Modern Type Features
```python
from typing import TypeIs, TypeVar, ReadOnly, TypedDict

# TypeIs - replacement for TypeGuard with better narrowing
def is_string_list(val: list[object]) -> TypeIs[list[str]]:
    return all(isinstance(x, str) for x in val)

# TypeVar with defaults (PEP 696)
T = TypeVar('T', default=str)  # Defaults to str if not specified

# ReadOnly for TypedDict fields
class Config(TypedDict):
    name: str
    version: ReadOnly[str]  # Cannot be modified after creation
```

### Better Generics with Defaults
```python
from typing import TypeVar, Generic

# TypeVar with default value
T = TypeVar('T', default=str)
K = TypeVar('K', default=int)

class Container(Generic[T, K]):
    def __init__(self, item: T, key: K) -> None:
        self.item = item
        self.key = key

# Can instantiate with partial type args
box: Container[bytes] = Container(b"data", 42)  # K defaults to int
```

## Type hints (mandatory)
- ALL functions must have parameter and return type hints
- ALL methods must have type hints
- ALL class attributes must have type annotations
- Use `from __future__ import annotations` for forward references

## MyPy Strict Mode (see `.github/skills/mypy-strict-typing/SKILL.md`)

All code must pass `uv run mypy --strict src/` with zero errors.

### Required Patterns
- Fully typed function signatures (parameters AND return types)
- Declare `-> None` for functions that return nothing
- Use modern generics: `list[T]`, `dict[str, int]`, `set[Item]`
- Use `| None` instead of `Optional[T]` (Python 3.11+ style)
- Use `TypedDict` for structured dictionary types
- Use `Protocol` for duck typing / structural subtyping
- Use `TypeIs` for type narrowing (replaces `TypeGuard` in Python 3.13+)

### Type Narrowing with TypeIs
```python
from typing import TypeIs, assert_type
from collections.abc import Sequence

# TypeIs narrows in both branches (unlike TypeGuard)
def is_str_list(val: list[int] | list[str]) -> TypeIs[list[str]]:
    return all(isinstance(x, str) for x in val)

def process(val: list[int] | list[str]) -> None:
    if is_str_list(val):
        assert_type(val, list[str])  # Type is narrowed to list[str]
    else:
        assert_type(val, list[int])  # Type is narrowed to list[int]
```

### Overload Patterns
```python
from typing import overload, Literal

@overload
def fetch(url: str, json: Literal[True]) -> dict[str, object]: ...
@overload
def fetch(url: str, json: Literal[False] = ...) -> str: ...

def fetch(url: str, json: bool = False) -> dict[str, object] | str:
    # Implementation
    ...
```

### Callable Types
```python
from collections.abc import Callable, Awaitable

async def with_retry(
    fn: Callable[[], Awaitable[T]],
    max_retries: int = 3,
) -> T:
    ...
```

### Forbidden
- `# type: ignore` without specific error code (use `# type: ignore[error-code]`)
- `Any` type when a specific type is possible
- Untyped function parameters or return values
- `cast()` without justification comment

## Style
- Follow PEP 8 strictly
- Follow PEP 257 for docstrings
- Maximum line length: 100 characters
- Use descriptive variable and function names
- Keep functions small and focused (single responsibility)
- Avoid nested conditionals deeper than 3 levels

## Package Management - uv

`uv` is the standard package manager (not pip).

### Core Commands
```bash
# Install dependencies from pyproject.toml
uv sync

# Add a new dependency
uv add httpx

# Add a dev dependency
uv add --dev pytest

# Run a command in the virtual environment
uv run python script.py
uv run pytest
uv run mypy --strict src/

# Create lock file for reproducible builds
uv lock
```

### pyproject.toml Patterns
```toml
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.13"
dependencies = [
    "django>=5.1",
    "httpx>=0.27",
    "pydantic>=2.8",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-asyncio>=0.24",
    "mypy>=1.11",
    "ruff>=0.6",
]
```

### uv.lock
- Always commit `uv.lock` for reproducible builds
- Run `uv lock` after changing dependencies
- CI should use `uv sync --frozen` to ensure lock file matches

## Code Quality Tools

### Ruff (linting AND formatting)
Ruff replaces black, isort, flake8, and many other tools.

```toml
# pyproject.toml
[tool.ruff]
target-version = "py313"
line-length = 100
select = ["E", "F", "I", "UP", "B", "SIM", "C4", "DTZ", "T20", "RUF"]

[tool.ruff.lint]
ignore = []
fixable = ["ALL"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

### Rule Categories
| Code | Category | Purpose |
|------|----------|----------|
| E | Error | Pycodestyle errors |
| F | Pyflakes | Undefined names, unused imports |
| I | isort | Import sorting |
| UP | pyupgrade | Python version upgrades |
| B | flake8-bugbear | Common bugs |
| SIM | flake8-simplify | Simplification |
| C4 | flake8-comprehensions | Better comprehensions |
| DTZ | flake8-datetimez | Datetime issues |
| T20 | flake8-print | Print statements |
| RUF | Ruff-specific | Ruff's own rules |

### Usage
```bash
# Check for issues
uv run ruff check src/

# Auto-fix issues
uv run ruff check --fix src/

# Format code
uv run ruff format src/
```

## Documentation
- All public functions/methods/classes require docstrings
- Docstrings must document parameters, return values, and exceptions
- Use Google-style docstring format
- 100% docstring coverage enforced: `uv run interrogate src/ -v --fail-under=100`

### Google-style docstring example
```python
def function_name(param: Type) -> ReturnType:
    """Short description of function.

    Longer description if needed.

    Args:
        param: Description of parameter.

    Returns:
        Description of return value.

    Raises:
        ExceptionType: When this exception is raised.
    """
```

## Error handling

See `.github/skills/error-handling-patterns/SKILL.md` for complete patterns.

### Exception hierarchy
- All custom exceptions must inherit from `{ProjectError}`
- Use specific exception types: `ConfigurationError`, `AgentError`, `NetworkError`

### Rules
- Never catch generic `Exception` without specific handling
- Always preserve exception chain with `from` clause
- Log errors before raising with context
- Document exceptions in docstrings with `Raises:` section

### Django error responses
- Return consistent JSON: `{"error": "message"}` or `{"data": result}`
- Use appropriate HTTP status codes (400 for validation, 500 for internal)
- Never expose internal error details to clients

## Async Django Rules (Mandatory)

**Async-first is mandatory.** Avoid sync code at all costs.

### Priority Order (use first available option)
1. **Native async Django** - PREFERRED (async views, async ORM methods)
2. **Async libraries** - `httpx`, `aiofiles`, `aiosqlite`
3. **Creative async solutions** - find async patterns
4. **`sync_to_async`** - LAST RESORT only when no async alternative exists

### Required Practices
- ALL views must be async unless they have no I/O
- Use async ORM methods: `aget()`, `aexists()`, `acount()`, `aiterator()`
- Use `async for` for QuerySet iteration
- Use `httpx.AsyncClient` instead of `requests`
- Use `aiofiles` for file operations

### Forbidden (without explicit approval)
- Sync views with `sync_to_async` for simple cases
- Using `requests` library (use `httpx`)
- Sync file I/O (use `aiofiles`)
- `sync_to_async` when native async ORM method exists

## TDD requirement
- If modifying production code, ensure a failing test exists first
- Tests must be written before or alongside implementation
- Coverage must reach 75% line and branch (tracked separately for unit/integration)
- Abstract methods and `TYPE_CHECKING` blocks can be excluded

## pytest 8.x Features

### pytest-asyncio Strict Mode
```toml
# pyproject.toml
[tool.pytest.ini_options]
asyncio_mode = "strict"
asyncio_default_fixture_loop_scope = "function"
```

```python
import pytest

# All async tests must be explicitly marked
@pytest.mark.asyncio
async def test_async_operation() -> None:
    result = await some_async_function()
    assert result is not None
```

### Fixture Patterns
```python
import pytest
from collections.abc import AsyncIterator

# Session-scoped async fixture
@pytest.fixture(scope="session")
async def db_connection() -> AsyncIterator[Connection]:
    conn = await create_connection()
    yield conn
    await conn.close()

# Function-scoped fixture with cleanup
@pytest.fixture
async def test_user(db_connection: Connection) -> AsyncIterator[User]:
    user = await User.objects.acreate(name="test")
    yield user
    await user.adelete()
```

### conftest.py Organization
```
tests/
├── conftest.py          # Shared fixtures, pytest plugins
├── unit/
│   ├── conftest.py      # Unit test specific fixtures
│   └── test_*.py
├── integration/
│   ├── conftest.py      # Integration fixtures (DB, external services)
│   └── test_*.py
```

### Parametrize with Dataclasses
```python
from dataclasses import dataclass
import pytest

@dataclass(frozen=True)
class ValidationCase:
    input_value: str
    expected: bool
    description: str

VALIDATION_CASES = [
    ValidationCase("valid@email.com", True, "valid email"),
    ValidationCase("invalid", False, "missing @"),
    ValidationCase("", False, "empty string"),
]

@pytest.mark.parametrize(
    "case",
    VALIDATION_CASES,
    ids=lambda c: c.description,
)
def test_email_validation(case: ValidationCase) -> None:
    assert validate_email(case.input_value) == case.expected
```

## Django Migrations

See `.github/skills/django-migrations/SKILL.md` for complete patterns.

### Key Rules
- Use descriptive migration names: `--name add_user_preferences`
- Define async model methods using `asave()`, `aget()`, `aexists()`
- Always provide reverse operations for data migrations
- Use `abulk_create()` for async bulk operations in migrations
- Squash old migrations for production: `squashmigrations myapp 0001 0050`

## Environment Variables

### Naming Convention
All project-specific environment variables **MUST** use the `{PROJECT_PREFIX}_` prefix:

| Variable | Purpose | Fallback |
|----------|---------|----------|
| `{PROJECT_PREFIX}_OPENAI_API_KEY` | OpenAI API key | `OPENAI_API_KEY` |
| `{PROJECT_PREFIX}_ANTHROPIC_API_KEY` | Anthropic API key | `ANTHROPIC_API_KEY` |
| `{PROJECT_PREFIX}_DEBUG` | Enable debug mode | None |
| `{PROJECT_PREFIX}_LOG_LEVEL` | Logging level | `INFO` |

### Precedence
1. `{PROJECT_PREFIX}_*` prefix (highest priority)
2. Generic provider variables
3. Default values

### Pydantic Settings Pattern
```python
from pydantic_settings import BaseSettings

class {ProjectSettings}(BaseSettings):
    """Project configuration with env var support."""
    
    openai_api_key: str | None = None
    anthropic_api_key: str | None = None
    debug: bool = False
    log_level: str = "INFO"
    
    model_config = {"env_prefix": "{PROJECT_PREFIX}_"}
```

### Manual Env Var Reading
When not using Pydantic, always check `{PROJECT_PREFIX}_*` first:
```python
import os

def get_api_key() -> str | None:
    """Get API key with {PROJECT_PREFIX}_ prefix priority."""
    return os.environ.get("{PROJECT_PREFIX}_OPENAI_API_KEY") or os.environ.get("OPENAI_API_KEY")
```

## Pydantic Models

See `.github/skills/pydantic-conventions/SKILL.md` for complete patterns.

### Model Definition
- Use `model_config` dict, not deprecated `class Config`
- Use `Field()` with constraints: `ge`, `le`, `min_length`, `max_length`, `gt`, `lt`
- Use modern type hints: `list[str]`, `dict[str, int]`, `str | None`

### Validators
- Use `@field_validator` with `@classmethod` decorator (not `@validator`)
- Use `@model_validator` for cross-field validation

### Settings
- Use `BaseSettings` from `pydantic_settings` for env var configuration
- Use `SettingsConfigDict` for settings configuration
- Always use `env_prefix="{PROJECT_PREFIX}_"`

### Serialization
- Use `model_dump()` not deprecated `dict()`
- Use `model_dump_json()` not deprecated `json()`
- Use `model_validate()` not deprecated `parse_obj()`

## Logging

See `.github/skills/logging-standards/SKILL.md` for complete patterns.

### Basic Setup
```python
import logging

logger = logging.getLogger(__name__)
```

### Rules
- Use module-level loggers with `__name__`
- Use `extra` parameter for structured data, not f-strings
- Never log secrets, credentials, or sensitive data
- Use `logger.exception()` in except blocks to capture stack traces

## Quality Gates

All code must pass these quality gates before merging:

| Gate | Requirement | Command |
|------|-------------|----------|
| Coverage | 75% line + 75% branch minimum | `uv run pytest --cov --cov-branch --cov-fail-under=75` |
| Type checking | Zero errors | `uv run mypy --strict src/` |
| Linting | Zero errors | `uv run ruff check src/` |
| Formatting | Consistent | `uv run ruff format --check src/` |
| Docstrings | 100% coverage | `uv run interrogate src/ -v --fail-under=100` |

### Pre-commit Hook (recommended)
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

### CI Pipeline Requirements
```bash
# All commands must pass with exit code 0
uv sync --frozen
uv run ruff check src/
uv run ruff format --check src/
uv run mypy --strict src/
uv run pytest --cov --cov-branch --cov-fail-under=75
uv run interrogate src/ -v --fail-under=100
```

## Forbidden practices
- `# type: ignore` without specific error code and justification
- `# pragma: no cover` on code that should be testable
- `Any` type when a specific type is possible
- Debug print statements in committed code
- Hardcoded credentials or secrets
- Logging secrets, API keys, or authentication tokens
