---
applyTo: "**/tests/**/*.py,**/test_*.py,**/*_test.py"
---

# Test code rules

## Organization
- Unit tests in `tests/unit/` with `@pytest.mark.unit` marker
- Integration tests in `tests/integration/` with `@pytest.mark.integration` marker
- E2E tests in `tests/e2e/` with `@pytest.mark.e2e` marker
- Fixtures in `tests/fixtures/` or `conftest.py`

## Test quality
- **Deterministic**: no random failures, no sleep-based timing
- **Isolated**: tests must not depend on each other or global state
- **Fast**: unit tests should complete quickly
- **Clear**: descriptive names following `test_<function>_<scenario>_<expected>`

## Structure
- Follow Arrange-Act-Assert pattern
- One assertion per test when possible
- Use fixtures for setup, not inline code
- Separate test data from test logic

## Coverage requirements
- **≥75% line coverage** (required for unit tests)
- **≥75% branch coverage** (required for unit tests)
- **≥75% line coverage** (required for integration tests, tracked separately)
- **≥75% branch coverage** (required for integration tests, tracked separately)
- All edge cases must be tested
- All error conditions must be tested
- Abstract methods and `TYPE_CHECKING` blocks can be excluded from coverage

## Complexity Thresholds

### Source Code (src/)
- Cyclomatic complexity: CC ≤ 5 (grade A)
- Maintainability index: MI ≥ 20 (grade A)

### Test Code (tests/)
- Cyclomatic complexity: CC ≤ 10 (grade B)
- Maintainability index: MI ≥ 10 (grade B)

### Commands
```bash
# For source code (strict)
uv run radon cc src/ -a -nb --total-average
uv run radon mi src/ -nb

# For tests (relaxed)
uv run radon cc tests/ -a -nc --total-average  # -nc allows up to B grade
uv run radon mi tests/ -nc
```

## Async tests
- Use `@pytest.mark.asyncio` decorator for async tests
- Use `AsyncMock` for mocking async functions
- No blocking calls in async tests
- Use proper async fixtures

```python
import pytest
from unittest.mock import AsyncMock

@pytest.mark.asyncio
async def test_async_function() -> None:
    """Example async test with proper typing."""
    mock = AsyncMock(return_value={"status": "ok"})
    result = await mock()
    assert result["status"] == "ok"
```

## Mocking
- Mock external dependencies only, never the system under test
- Use realistic mock responses
- Verify mock interactions where relevant
- Clean up mocks after tests

## Parallel Test Execution (pytest-xdist)

Tests run in parallel with `pytest -n auto`. Every test must be:

### Encapsulated (No Shared State)
- Each test must create its own fixtures, never rely on test execution order
- Use `tmp_path` fixture for temporary files, not hardcoded paths
- Use unique database names or in-memory databases per test

### Self-Contained Resources
- Mock external services in each test, not globally
- Clean up after yourself in finally blocks or fixtures with yield
- Never write to shared directories

### Forbidden Patterns
- `pytest.mark.order` - tests must not depend on order
- Global mutable state modified between tests
- Fixed port numbers (use `0` for random available port)
- `time.sleep()` for synchronization

### Correct Pattern
```python
@pytest.fixture
async def isolated_client(tmp_path: Path) -> AsyncGenerator[Client, None]:
    """Create isolated client with temp database."""
    db = tmp_path / "test.db"
    client = await Client.create(db)
    try:
        yield client
    finally:
        await client.close()
```

## Conftest.py Organization

### File Placement
- Root `tests/conftest.py` for shared fixtures
- Module `tests/unit/conftest.py` for unit-specific fixtures
- `tests/integration/conftest.py` for integration-specific fixtures

### Fixture Scope
```python
import pytest
from collections.abc import AsyncGenerator

@pytest.fixture  # function scope (default) - most isolated
async def client() -> AsyncGenerator[Client, None]:
    c = await Client.create()
    try:
        yield c
    finally:
        await c.close()

@pytest.fixture(scope="module")  # shared within module
async def database() -> AsyncGenerator[Database, None]:
    db = await Database.create_for_tests()
    try:
        yield db
    finally:
        await db.drop()

@pytest.fixture(scope="session")  # shared across all tests
def event_loop_policy():
    return asyncio.DefaultEventLoopPolicy()
```

### Fixture Organization Patterns

```python
# tests/conftest.py - Shared fixtures only
import pytest
from pathlib import Path
from collections.abc import AsyncGenerator

@pytest.fixture
def tmp_config(tmp_path: Path) -> Path:
    """Temporary config file."""
    config = tmp_path / "config.json"
    config.write_text('{}')
    return config

@pytest.fixture
async def mock_api() -> AsyncGenerator[MockAPI, None]:
    """Mock external API for all tests."""
    api = MockAPI()
    await api.start()
    try:
        yield api
    finally:
        await api.stop()
```

### Auto-use Fixtures
Use sparingly for setup needed by every test:

```python
@pytest.fixture(autouse=True)
def reset_environment(monkeypatch: pytest.MonkeyPatch) -> None:
    """Reset environment for every test."""
    monkeypatch.delenv("{PROJECT_PREFIX}_API_KEY", raising=False)
```

### Fixture Factories
For parameterized fixtures:

```python
@pytest.fixture
def task_factory() -> Callable[..., Task]:
    """Factory for creating test tasks."""
    def _factory(title: str = "Test", **kwargs: Any) -> Task:
        return Task(title=title, **{**DEFAULT_ATTRS, **kwargs})
    return _factory
```

## CLI Testing (Typer)

For testing Typer CLI commands, see the `typer-cli-testing` skill.

```python
from typer.testing import CliRunner
from {project_package}.cli.main import app

runner = CliRunner()

def test_cli_command() -> None:
    """Test CLI command execution."""
    result = runner.invoke(app, ["sub-command", "--option", "value"])
    assert result.exit_code == 0
    assert "expected output" in result.stdout
```

### Key patterns
- Use `CliRunner` for isolated CLI testing
- Test exit codes for error handling
- Use `monkeypatch.setenv()` for environment variables
- Use `input="yes\n"` for interactive prompts
- Use `tmp_path` with `{PROJECT_PREFIX}_CONFIG_DIR` for isolated config

## Forbidden
- `@pytest.mark.skip` without justification
- Sleep-based assertions
- Tests that modify global state without cleanup
- Flaky tests that occasionally fail
- Hardcoded paths or credentials
