---
applyTo: "**/e2e/**/*.py,**/playwright/**/*.py,**/tests/e2e/**/*.py"
---

# Playwright E2E test rules

## Test location
- Place E2E tests in `tests/e2e/` directory
- Use `@pytest.mark.e2e` marker
- Use pytest-playwright for fixtures

## Artifact policy
- Screenshots captured on failure (mandatory)
- Traces retained on failure
- Videos optional, retain on failure when needed

## Test patterns

### Sync tests (preferred for simplicity)
```python
import pytest
from playwright.sync_api import Page, expect

@pytest.mark.e2e
def test_user_journey(page: Page) -> None:
    """Test complete user flow."""
    page.goto("/")
    expect(page).to_have_title("{ProjectName}")
```

### Async tests (when needed)
```python
import pytest
from playwright.async_api import Page, expect

@pytest.mark.asyncio
@pytest.mark.e2e
async def test_async_journey(page: Page) -> None:
    """Async E2E test."""
    await page.goto("/")
    await expect(page).to_have_title("{ProjectName}")
```

## Best practices
- Use locators that are stable (data-testid, roles, accessible names)
- Prefer `expect()` assertions over manual waits
- Capture meaningful screenshots at key points
- Test critical user journeys, not every interaction
- Handle loading states explicitly

## Locator strategy (in order of preference)
1. `data-testid` attributes: `page.locator("[data-testid=submit-btn]")`
2. ARIA roles: `page.get_by_role("button", name="Submit")`
3. Accessible names: `page.get_by_label("Email")`
4. CSS selectors (last resort): `page.locator(".submit-button")`

## Forbidden
- Arbitrary sleeps: use `expect()` with timeouts instead
- Fragile selectors that break with minor UI changes
- Tests without assertions
- Tests that depend on external services without mocking
