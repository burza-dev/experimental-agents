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
  name: app_db

# Bad: Inconsistent naming
database:
  HOST: localhost     # Don't mix cases
  dbPort: 5432        # Don't mix naming styles
```

### Environment Variables
Reference environment variables explicitly:

```yaml
api:
  key: "${API_KEY}"
  timeout: "${TIMEOUT:-30}"  # With default
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
name = "my-project"
version = "0.1.0"
description = "Project description"
requires-python = ">=3.11"

[project.dependencies]
# Example dependencies
```

### Tool Configuration
```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]
```

### Dependencies
```toml
[project.dependencies]
# Pin major versions, allow minor updates
# example-lib = ">=1.0,<2.0"

[project.optional-dependencies]
dev = [
    # Development dependencies
]
```

## Forbidden Patterns
- Tabs for indentation
- Inline comments that wrap lines
- Unquoted strings with special characters
- Duplicate keys
- Mixing naming conventions (snake_case vs camelCase)
