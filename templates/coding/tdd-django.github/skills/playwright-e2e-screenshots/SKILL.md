---
name: playwright-e2e-screenshots
description: Write and run Playwright E2E tests with pytest-playwright, enabling screenshot capture (at least on failure) and trace retention. Use when implementing browser-based E2E for web apps, adding screenshot artifacts, or troubleshooting flaky UI tests.
license: MIT
---

# Playwright E2E + screenshots (pytest)

## Purpose

Implement browser-based end-to-end tests with:
- Screenshot capture (mandatory on failure)
- Trace retention for debugging
- Optional video recording
- Visual regression testing support

## Test organization

- Place E2E tests in `tests/e2e/` directory
- Use `@pytest.mark.e2e` marker
- Use sync or async Playwright API as appropriate

## Default artifact policy

| Artifact | Policy | Rationale |
|----------|--------|-----------|
| Screenshots | only-on-failure | Capture state at failure point |
| Traces | retain-on-failure | Full action log for debugging |
| Videos | retain-on-failure | Visual replay of test run |

## Commands (generic)

```bash
# Basic E2E run with screenshots
uv run pytest tests/e2e/ --screenshot only-on-failure --full-page-screenshot

# With trace retention
uv run pytest tests/e2e/ --screenshot only-on-failure --tracing retain-on-failure

# With video recording
uv run pytest tests/e2e/ --screenshot only-on-failure --video retain-on-failure

# Specify output directory
uv run pytest tests/e2e/ --screenshot only-on-failure --output ./test-results/

# Run headed (visible browser)
uv run pytest tests/e2e/ --headed

# Run in specific browser
uv run pytest tests/e2e/ --browser chromium
uv run pytest tests/e2e/ --browser firefox
uv run pytest tests/e2e/ --browser webkit
```

## Test patterns

### Sync Playwright

```python
import pytest
from playwright.sync_api import Page, expect

@pytest.mark.e2e
def test_login_flow(page: Page) -> None:
    """Test user login journey."""
    page.goto("/login")
    page.fill("[name=username]", "testuser")
    page.fill("[name=password]", "password123")
    page.click("[type=submit]")
    
    expect(page).to_have_url("/dashboard")
    expect(page.locator("h1")).to_contain_text("Welcome")
```

### Async Playwright

```python
import pytest
from playwright.async_api import Page, expect

@pytest.mark.asyncio
@pytest.mark.e2e
async def test_async_flow(page: Page) -> None:
    """Async E2E test."""
    await page.goto("/")
    await expect(page).to_have_title("{ProjectName}")
```

### Manual screenshot capture

```python
@pytest.mark.e2e
def test_with_screenshots(page: Page) -> None:
    """Test with explicit screenshots."""
    page.goto("/dashboard")
    page.screenshot(path="screenshots/dashboard.png", full_page=True)
    
    page.click("[data-action=submit]")
    page.screenshot(path="screenshots/after-submit.png")
```

## Configuration

### pytest.ini / pyproject.toml

```toml
[tool.pytest.ini_options]
markers = [
    "e2e: End-to-end browser tests",
]
```

### conftest.py for E2E

```python
import pytest
from playwright.sync_api import Browser

@pytest.fixture(scope="session")
def browser_context_args(browser_context_args: dict) -> dict:
    """Custom browser context settings."""
    return {
        **browser_context_args,
        "viewport": {"width": 1280, "height": 720},
        "locale": "en-US",
    }
```

## Visual regression

For snapshot-based visual regression:

```python
@pytest.mark.e2e
def test_visual_regression(page: Page, snapshot) -> None:
    """Compare against baseline screenshot."""
    page.goto("/dashboard")
    assert page.screenshot() == snapshot
```

Update baselines with: `--update-snapshots`

## Reporting requirements

Always report:
- Commands executed
- Artifact directories created/used
- User journeys covered
- Screenshot file locations
- Any flaky behavior observed
