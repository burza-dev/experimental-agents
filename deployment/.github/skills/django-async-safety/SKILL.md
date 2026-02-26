---
name: django-async-safety
description: Guidance for writing safe async Django (ASGI) code and tests. Use when implementing async views/middleware, touching ORM inside async code, or debugging SynchronousOnlyOperation issues.
license: MIT
---

# Async Django Safety (Mandatory Rules)

## Core Principles (ENFORCED)

**Async-first is mandatory.** ALL async functionalities that CAN be implemented in native async Django MUST be implemented that way. Agents must avoid sync code at all costs.

### Priority Order (use first available option)
1. **Native async Django** - PREFERRED (async views, `aget()`, `aexists()`, `acount()`)
2. **Async libraries** - `httpx`, `aiofiles`, `aiosqlite` instead of sync equivalents
3. **Creative async solutions** - find async patterns for common operations
4. **`sync_to_async`** - LAST RESORT only when no async alternative exists

### Absolutely Required
- ALL views must be async unless they have no I/O operations
- Use async ORM methods: `aget()`, `aexists()`, `acount()`, `aiterator()`
- Use `async for` for QuerySet iteration
- Use `httpx.AsyncClient` instead of `requests`
- Use `aiofiles` for file operations

### Forbidden (without explicit approval)
- Sync views with `sync_to_async` for simple cases
- Using `requests` library (must use `httpx`)
- Sync file I/O (must use `aiofiles`)
- Blocking operations in async contexts
- `sync_to_async` when native async ORM method exists

## Safe patterns

### Async view with ORM access

```python
from asgiref.sync import sync_to_async
from django.http import JsonResponse

async def async_view(request):
    """Async view with safe ORM access."""
    # Wrap sync ORM call
    user = await sync_to_async(User.objects.get)(pk=request.user.id)
    
    # Or use thread_sensitive=False for independent operations
    users = await sync_to_async(list, thread_sensitive=False)(
        User.objects.filter(is_active=True)
    )
    
    return JsonResponse({"count": len(users)})
```

### Async ORM methods (Django 4.1+) - ALWAYS USE THESE FIRST

```python
# MANDATORY: Use native async ORM methods - these are REQUIRED
async def async_view(request):
    # ✅ REQUIRED: Native async methods
    user = await User.objects.aget(pk=1)  # NOT sync_to_async(User.objects.get)
    exists = await User.objects.filter(email=email).aexists()  # NOT sync_to_async
    count = await User.objects.acount()  # NOT sync_to_async
    
    # ✅ REQUIRED: Async iteration with async for
    async for user in User.objects.filter(is_active=True):
        process(user)
    
    # ✅ REQUIRED: Use aiterator() for large querysets
    async for user in User.objects.filter(is_active=True).aiterator():
        process(user)
```

### Available Native Async ORM Methods (always prefer these)

| Sync Method | Async Method | Use Case |
|-------------|--------------|----------|
| `get()` | `aget()` | Single object retrieval |
| `create()` | `acreate()` | Object creation |
| `update()` | `aupdate()` | Queryset update |
| `delete()` | `adelete()` | Object/queryset deletion |
| `save()` | `asave()` | Object save |
| `count()` | `acount()` | Count queryset |
| `exists()` | `aexists()` | Check existence |
| `first()` | `afirst()` | Get first object |
| `last()` | `alast()` | Get last object |
| `contains()` | `acontains()` | Check if queryset contains object |
| `iterator()` | `aiterator()` | Memory-efficient iteration |
| `for obj in qs` | `async for obj in qs` | QuerySet iteration |

### Async middleware

```python
class AsyncMiddleware:
    async_capable = True
    sync_capable = False
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    async def __call__(self, request):
        # Pre-processing
        response = await self.get_response(request)
        # Post-processing
        return response
```

## Dangerous patterns (avoid!)

### SynchronousOnlyOperation triggers

```python
# BAD: Sync ORM call in async context
async def bad_view(request):
    user = User.objects.get(pk=1)  # Raises SynchronousOnlyOperation!
    
# BAD: Blocking I/O in async context
async def bad_io_view(request):
    with open("file.txt") as f:  # Blocks event loop!
        content = f.read()
```

### Fixed versions

```python
from asgiref.sync import sync_to_async
import aiofiles

# GOOD: Wrapped ORM call
async def good_view(request):
    user = await sync_to_async(User.objects.get)(pk=1)

# GOOD: Async file I/O
async def good_io_view(request):
    async with aiofiles.open("file.txt") as f:
        content = await f.read()
```

## Testing async Django

### pytest-asyncio configuration

```toml
# pyproject.toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
```

### Async test pattern

```python
import pytest
from asgiref.sync import sync_to_async

@pytest.mark.asyncio
@pytest.mark.django_db
async def test_async_view() -> None:
    """Test async view with database."""
    # Create test data synchronously (in setup) or wrap
    user = await sync_to_async(User.objects.create)(
        username="test",
        email="test@example.com"
    )
    
    # Test async functionality
    result = await async_function(user.id)
    assert result is not None
```

### AsyncClient for testing

```python
from django.test import AsyncClient

@pytest.mark.asyncio
@pytest.mark.django_db
async def test_async_endpoint() -> None:
    """Test endpoint with AsyncClient."""
    client = AsyncClient()
    response = await client.get("/api/users/")
    assert response.status_code == 200
```

## Implementation checklist (MANDATORY)

When touching async code:
- [ ] ALL views are async unless they have no I/O
- [ ] Native async ORM methods used FIRST (aget, aexists, acount, aiterator)
- [ ] `async for` used for QuerySet iteration
- [ ] `httpx.AsyncClient` used instead of `requests`
- [ ] `aiofiles` used for file operations
- [ ] `sync_to_async` ONLY used when no native async method exists
- [ ] Verify no SynchronousOnlyOperation raised
- [ ] Test concurrent request scenarios
- [ ] Test async code paths explicitly

### Before using `sync_to_async`, verify:
- [ ] No native async ORM method exists for this operation
- [ ] No async library alternative exists
- [ ] Document why `sync_to_async` was necessary

## Reporting requirements

When async code is added/changed, report:
- Which code paths are async
- Which boundaries to sync components exist
- How sync operations are handled
- Test coverage for async paths
- Any concurrency hazards identified
