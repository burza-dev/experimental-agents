---
name: docstring-coverage
description: Enforce 100% docstring coverage on source code using interrogate. Use when adding or validating docstrings, when docstring coverage thresholds are required (100% for this project), or when reviewing code for documentation completeness.
license: MIT
---

# Docstring coverage enforcement

## Goal

Ensure all functions, classes, and methods in source code have docstrings:
- **100% docstring coverage** required for `src/`
- Use Google-style docstring format
- Enforced via `interrogate` tool

## When to use this skill

- Adding new functions, classes, or methods
- Reviewing code for documentation completeness
- Running quality gates before merge
- Fixing docstring coverage failures

## Commands

```bash
# Check docstring coverage (100% required for source code)
uv run interrogate src/ -v --fail-under=100

# Verbose output to see missing docstrings
uv run interrogate src/ -vv

# Generate coverage report
uv run interrogate src/ -v --generate-badge .

# Check specific file
uv run interrogate src/{project_package}/module.py -vv
```

## Google-style docstring format

All docstrings must follow Google-style format:

### Function/method docstring

```python
def function_name(param: Type, optional_param: Type | None = None) -> ReturnType:
    """Short description of function.

    Longer description if needed. Explain what the function does,
    any important behavior, and usage context.

    Args:
        param: Description of parameter.
        optional_param: Description of optional parameter.

    Returns:
        Description of return value.

    Raises:
        ExceptionType: When this exception is raised.
        AnotherException: When this other condition occurs.
    """
```

### Class docstring

```python
class MyClass:
    """Short description of class.

    Longer description explaining the purpose and usage of the class.

    Attributes:
        attribute_name: Description of the attribute.
        another_attr: Description of another attribute.

    Example:
        >>> obj = MyClass()
        >>> obj.method()
    """
```

### Module docstring

```python
"""Short description of module.

This module provides functionality for X. It includes classes
and functions for handling Y and Z.

Example:
    >>> from {project_package}.module import MyClass
    >>> obj = MyClass()
"""
```

## Configuration

Configure interrogate in `pyproject.toml`:

```toml
[tool.interrogate]
ignore-init-method = true
ignore-init-module = true
ignore-magic = true
ignore-semiprivate = false
ignore-private = false
ignore-property-decorators = false
ignore-module = false
ignore-nested-functions = false
ignore-nested-classes = false
fail-under = 100
verbose = 1
quiet = false
whitelist-regex = []
color = true
omit-covered-files = false
```

## Common issues and fixes

### Missing function docstring

```python
# Before (fails)
def process_data(data: list[str]) -> dict[str, int]:
    return {item: len(item) for item in data}

# After (passes)
def process_data(data: list[str]) -> dict[str, int]:
    """Process data items into length mapping.

    Args:
        data: List of strings to process.

    Returns:
        Dictionary mapping each string to its length.
    """
    return {item: len(item) for item in data}
```

### Missing class docstring

```python
# Before (fails)
class DataProcessor:
    def __init__(self, config: Config) -> None:
        self.config = config

# After (passes)
class DataProcessor:
    """Process data according to configuration.

    Attributes:
        config: Configuration for data processing.
    """

    def __init__(self, config: Config) -> None:
        """Initialize processor with configuration.

        Args:
            config: Configuration object for processing.
        """
        self.config = config
```

## Integration with CI/CD

Add to your CI pipeline:

```yaml
- name: Check docstring coverage
  run: uv run interrogate src/ -v --fail-under=100
```

## References

- [interrogate documentation](https://interrogate.readthedocs.io/)
- [Google Python Style Guide - Docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
- [PEP 257 - Docstring Conventions](https://peps.python.org/pep-0257/)
