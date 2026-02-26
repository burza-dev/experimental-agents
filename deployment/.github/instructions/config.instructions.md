---
applyTo: "**/*.{yaml,yml,toml}"
---

# Configuration File Rules

## YAML Files

### Formatting
- Use 2 spaces for indentation (no tabs)
- No trailing whitespace
- Single empty line at end of file
- Quote strings containing special characters

### Structure
```yaml
# Good: Clear key naming
database:
  host: localhost
  port: 5432
  name: {project_name}_db

# Bad: Inconsistent naming
database:
  HOST: localhost     # Don't mix cases
  dbPort: 5432        # Don't mix naming styles
```

### Environment Variables
Reference environment variables explicitly:

```yaml
api:
  key: "${{{PROJECT_PREFIX}_API_KEY}}"
  timeout: "${{{PROJECT_PREFIX}_TIMEOUT:-30}}"  # With default
```

### Lists
```yaml
# Preferred: Block style for complex items
agents:
  - name: manager
    enabled: true
  - name: architect
    enabled: true

# Acceptable: Flow style for simple items
tags: [python, django, async]
```

## TOML Files (pyproject.toml)

### Project Configuration
```toml
[project]
name = "{project_name}"
version = "0.1.0"
description = "AI Coding Agent Orchestrator"
requires-python = ">=3.11"

[project.dependencies]
django = ">=6.0"
pydantic = ">=2.0"
```

### Tool Configuration
```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]

[tool.mypy]
strict = true
python_version = "3.11"

[tool.pytest.ini_options]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "function"
```

### Dependencies
```toml
[project.dependencies]
# Pin major versions, allow minor updates
django = ">=6.0,<7.0"
pydantic = ">=2.0"

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "ruff>=0.4",
    "mypy>=1.10",
]
```

## Forbidden Patterns
- Tabs for indentation
- Inline comments that wrap lines
- Unquoted strings with special characters
- Duplicate keys
- Mixing naming conventions (snake_case vs camelCase)
