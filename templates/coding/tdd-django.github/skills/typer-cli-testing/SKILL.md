---
name: typer-cli-testing
description: Patterns for testing Typer CLI commands. Use when writing tests for CLI modules in your project.
---

# Typer CLI Testing Patterns

## CliRunner Setup
Use Typer's CliRunner for isolated CLI testing:

```python
import pytest
from typer.testing import CliRunner
from {project_package}.cli.main import app

runner = CliRunner()

def test_cli_command() -> None:
    """Test CLI command execution."""
    result = runner.invoke(app, ["sub-command", "--option", "value"])
    assert result.exit_code == 0
    assert "expected output" in result.stdout
```

## Testing Exit Codes
```python
def test_cli_error_handling() -> None:
    """Test CLI returns correct exit code on error."""
    result = runner.invoke(app, ["invalid-command"])
    assert result.exit_code == 2  # Typer's default for invalid command
```

## Testing with Environment Variables
```python
def test_cli_with_env(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test CLI reads environment variables."""
    monkeypatch.setenv("{PROJECT_PREFIX}_API_KEY", "test-key")
    result = runner.invoke(app, ["auth", "status"])
    assert result.exit_code == 0
```

## Testing Interactive Prompts
```python
def test_cli_with_input() -> None:
    """Test CLI with user input."""
    result = runner.invoke(app, ["setup"], input="yes\n")
    assert result.exit_code == 0
    assert "Setup complete" in result.stdout
```

## Async CLI Commands
For async commands using `asyncer`:

```python
import pytest
from typer.testing import CliRunner
from {project_package}.cli.main import app

runner = CliRunner()

@pytest.mark.asyncio
async def test_async_cli_command() -> None:
    """Test async CLI command."""
    # CliRunner handles async internally
    result = runner.invoke(app, ["async-operation"])
    assert result.exit_code == 0
```

## Isolated Config Testing
```python
def test_cli_config(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """Test CLI with isolated config directory."""
    config_dir = tmp_path / ".{project_name}"
    config_dir.mkdir()
    monkeypatch.setenv("{PROJECT_PREFIX}_CONFIG_DIR", str(config_dir))
    
    result = runner.invoke(app, ["config", "show"])
    assert result.exit_code == 0
```

## Rich Console Output Testing
When testing Rich-formatted output:

```python
def test_cli_rich_output() -> None:
    """Test CLI with Rich console output."""
    result = runner.invoke(app, ["status"])
    # Rich markup is stripped in CliRunner
    assert "Status:" in result.stdout
```
