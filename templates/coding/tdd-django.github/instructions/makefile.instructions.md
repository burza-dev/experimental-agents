---
applyTo: "**/Makefile,**/makefile,**/*.mk"
---

# Makefile Rules for Django Projects

## Overview

Instructions for writing maintainable Makefiles that wrap common Django/Python
development tasks. Makefiles serve as a unified interface for running tests,
linting, formatting, migrations, and server management.

## Standards

### GNU Make 4.x Features
- Use `$(info ...)`, `$(warning ...)`, `$(error ...)` for diagnostics
- Use `.ONESHELL` when multi-line shell commands benefit from single shell

### POSIX Compatibility
- Avoid bash-isms in recipes for portability (use `/bin/sh` compatible syntax)
- Use `$(SHELL)` variable instead of hardcoding shell paths
- Prefer `printf` over `echo -e` for portable output

## Structure

### File Organization
1. Variables at top
2. PHONY declarations
3. Default target (`help` or `all`)
4. Development targets
5. Quality targets
6. Utility targets

```make
# 1. Variables
PYTHON := uv run python
PYTEST := uv run pytest
RUFF := uv run ruff
MYPY := uv run mypy
MANAGE := $(PYTHON) manage.py
PROJECT_PACKAGE := {project_package}

# 2. PHONY declarations
.PHONY: help all test lint format typecheck migrate run coverage clean

# 3. Default target
help:
	@echo "Available targets:"
	@echo "  run        - Start development server"
	@echo "  test       - Run test suite"
	@echo "  lint       - Run linter (ruff)"
	@echo "  format     - Format code (ruff)"
	@echo "  typecheck  - Run type checker (mypy)"
	@echo "  migrate    - Apply database migrations"
	@echo "  coverage   - Run tests with coverage report"
	@echo "  clean      - Remove build artifacts"
	@echo "  help       - Show this help"
```

### PHONY Targets
Declare all targets as PHONY since Django Makefiles rarely produce files:

```make
.PHONY: all help run test lint format typecheck migrate makemigrations \
        coverage clean shell superuser check
```

## Variables

### Standard Variable Names
```make
# Python tooling (via uv)
PYTHON := uv run python
PYTEST := uv run pytest
RUFF := uv run ruff
MYPY := uv run mypy
MANAGE := $(PYTHON) manage.py

# Project settings
PROJECT_PACKAGE := {project_package}
SRC_DIR := src
TESTS_DIR := tests
COV_FAIL_UNDER := 75

# Server settings
HOST ?= 0.0.0.0
PORT ?= 8000
```

### Variable Overrides
Allow environment-level overrides:

```make
# User can override: make test TESTS_DIR=tests/unit
TESTS_DIR ?= tests
COV_FAIL_UNDER ?= 75
PORT ?= 8000
```

## Standard Targets

### Development Targets

```make
# Start development server with uvicorn
run:
	uvicorn $(PROJECT_PACKAGE).asgi:application --reload --host $(HOST) --port $(PORT)

# Apply database migrations
migrate:
	$(MANAGE) migrate

# Create new migrations
makemigrations:
	$(MANAGE) makemigrations

# Open Django shell
shell:
	$(MANAGE) shell

# Create superuser
superuser:
	$(MANAGE) createsuperuser

# Install/sync dependencies
install:
	uv sync

# Install with dev dependencies
install-dev:
	uv sync --all-extras
```

### Quality Targets

```make
# Run test suite
test:
	$(PYTEST) -n auto $(TESTS_DIR)

# Run linter
lint:
	$(RUFF) check $(SRC_DIR) $(TESTS_DIR)
	$(MYPY) --strict $(SRC_DIR)

# Format code
format:
	$(RUFF) format $(SRC_DIR) $(TESTS_DIR)
	$(RUFF) check --fix $(SRC_DIR) $(TESTS_DIR)

# Type checking only
typecheck:
	$(MYPY) --strict $(SRC_DIR)

# Run tests with coverage
coverage:
	$(PYTEST) -n auto --cov=$(SRC_DIR) --cov-branch --cov-report=html \
		--cov-fail-under=$(COV_FAIL_UNDER) $(TESTS_DIR)

# Run all checks (for CI)
check: lint test
	@echo "All checks passed"
```

### Utility Targets

```make
# Remove build artifacts
clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .mypy_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name htmlcov -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	find . -name ".coverage" -delete 2>/dev/null || true

# Display help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Development:"
	@echo "  run            Start dev server (uvicorn)"
	@echo "  migrate        Apply migrations"
	@echo "  makemigrations Create migrations"
	@echo "  shell          Django shell"
	@echo "  superuser      Create superuser"
	@echo "  install        Sync dependencies (uv sync)"
	@echo ""
	@echo "Quality:"
	@echo "  test           Run tests (pytest)"
	@echo "  lint           Lint + type check"
	@echo "  format         Format code (ruff)"
	@echo "  typecheck      Type check (mypy --strict)"
	@echo "  coverage       Tests with coverage report"
	@echo "  check          All checks (lint + test)"
	@echo ""
	@echo "Utility:"
	@echo "  clean          Remove build artifacts"
	@echo "  help           Show this help"
```

## Complete Example

```make
# Project configuration
PROJECT_PACKAGE := {project_package}
SRC_DIR := src
TESTS_DIR := tests
COV_FAIL_UNDER := 75
HOST ?= 0.0.0.0
PORT ?= 8000

# Tool shortcuts
PYTHON := uv run python
PYTEST := uv run pytest
RUFF := uv run ruff
MYPY := uv run mypy
MANAGE := $(PYTHON) manage.py

# All targets are phony (no file outputs)
.PHONY: help run test lint format typecheck migrate makemigrations \
        shell superuser install coverage check clean

# Default target
.DEFAULT_GOAL := help

run:
	uvicorn $(PROJECT_PACKAGE).asgi:application --reload --host $(HOST) --port $(PORT)

test:
	$(PYTEST) -n auto $(TESTS_DIR)

lint:
	$(RUFF) check $(SRC_DIR) $(TESTS_DIR)
	$(MYPY) --strict $(SRC_DIR)

format:
	$(RUFF) format $(SRC_DIR) $(TESTS_DIR)
	$(RUFF) check --fix $(SRC_DIR) $(TESTS_DIR)

typecheck:
	$(MYPY) --strict $(SRC_DIR)

migrate:
	$(MANAGE) migrate

makemigrations:
	$(MANAGE) makemigrations

shell:
	$(MANAGE) shell

superuser:
	$(MANAGE) createsuperuser

install:
	uv sync

coverage:
	$(PYTEST) -n auto --cov=$(SRC_DIR) --cov-branch --cov-report=html \
		--cov-fail-under=$(COV_FAIL_UNDER) $(TESTS_DIR)

check: lint test
	@echo "All checks passed"

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .mypy_cache -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	rm -rf htmlcov .coverage

help:
	@echo "$(PROJECT_PACKAGE) - Development Commands"
	@echo "make run         → Start dev server"
	@echo "make test        → Run test suite"
	@echo "make lint        → Lint + type check"
	@echo "make format      → Auto-format code"
	@echo "make coverage    → Tests with coverage"
	@echo "make migrate     → Apply migrations"
	@echo "make check       → All CI checks"
	@echo "make clean       → Remove artifacts"
```

## Forbidden Patterns

### Syntax Errors
```make
# Bad: Spaces instead of tabs (Make REQUIRES tabs for recipes)
target:
    echo "This will fail"  # Uses spaces

# Good: Tab character for indentation
target:
	echo "This works"  # Uses tab
```

### Missing Declarations
```make
# Bad: Missing PHONY for non-file targets
test:
	pytest

# Good: Declare PHONY targets
.PHONY: test
test:
	pytest
```

### Hardcoded Paths
```make
# Bad: Hardcoded absolute paths
PYTHON := /usr/bin/python3

# Good: Use uv run or allow overrides
PYTHON ?= uv run python
```

### Other Forbidden Patterns
- Using `pip install` instead of `uv sync`
- Missing `help` target
- Missing `.PHONY` declarations
- Hardcoded port numbers without variable override
- Recipes that silently swallow errors
