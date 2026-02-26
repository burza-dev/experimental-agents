---
name: pytest-coverage-gates
description: Enforce pytest coverage gates with pytest-cov (line+branch). Use when adding or validating unit/integration tests, when coverage thresholds are required (≥75% for this project), or when configuring pytest/coverage commands for Python projects.
license: MIT
---

# Pytest coverage gates (line + branch)

## Goal

Run pytest with enforced coverage thresholds:
- **≥75% line coverage** (required for unit tests)
- **≥75% branch coverage** (required for unit tests)
- **≥75% line coverage** (required for integration tests, tracked separately)
- **≥75% branch coverage** (required for integration tests, tracked separately)
- Abstract methods and `TYPE_CHECKING` blocks can be excluded from coverage

## Test organization (project-specific)

This project uses:
- **Markers**: `@pytest.mark.unit`, `@pytest.mark.integration`
- **Directories**: `tests/unit/`, `tests/integration/`
- Configuration in `pyproject.toml` under `[tool.pytest.ini_options]`

## Discovery steps

1. Check pytest configuration:
   - `pyproject.toml [tool.pytest.ini_options]`
   - `pytest.ini`
   - `setup.cfg [tool:pytest]`

2. Identify test markers and paths:
   - Look for marker definitions
   - Check test directory structure

3. Check coverage configuration:
   - `.coveragerc`
   - `pyproject.toml [tool.coverage.run]`

## Commands (project-specific)

```bash
# Run all tests with coverage
uv run pytest --cov --cov-branch --cov-fail-under=75

# Run all tests in parallel (pytest-xdist)
uv run pytest -n auto --cov --cov-branch --cov-fail-under=75

# Run unit tests only
uv run pytest tests/unit/ -m unit --cov --cov-branch --cov-report=term-missing

# Run integration tests only
uv run pytest tests/integration/ -m integration --cov --cov-branch --cov-report=term-missing

# Generate HTML coverage report
uv run pytest --cov --cov-branch --cov-report=html

# Check coverage without failing (for debugging)
uv run pytest --cov --cov-branch --cov-report=term-missing
```

## Coverage configuration

```toml
# pyproject.toml
[tool.coverage.run]
branch = true
source = ["src/{project_package}"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise NotImplementedError",
    "if TYPE_CHECKING:",
    "@abstractmethod",
]
fail_under = 75
```

## Reporting requirements

Always report:
- Exact command lines used
- Observed line coverage percentage
- Observed branch coverage percentage
- Any exclusions (`.coveragerc` / `omit`) that affect outcomes
- List of uncovered lines if < 75%

## Troubleshooting

### Coverage not reaching 75%
1. Check for unreachable code (dead code elimination)
2. Verify all exception handlers are tested
3. Check all conditional branches (if/else, try/except)
4. Look for early returns that bypass code

### pytest-cov not finding source
1. Verify `--cov={project_package}` or `--cov=src/{project_package}`
2. Check `source` setting in coverage config
3. Ensure `pythonpath` is set in pytest config
