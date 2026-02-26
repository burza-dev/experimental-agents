---
name: logging-standards
description: Logging conventions and best practices for your project. Apply when adding logging to any module.
---

# Logging Standards

## Logger Setup
Each module should have its own logger:

```python
import logging

logger = logging.getLogger(__name__)
```

## Log Levels
Use appropriate log levels:

| Level | When to use |
|-------|------------|
| DEBUG | Detailed diagnostic info (disabled in production) |
| INFO | Operational events (startup, shutdown, major operations) |
| WARNING | Unexpected but handled situations |
| ERROR | Errors that prevent an operation from completing |
| CRITICAL | System-wide failures |

## Structured Logging
Use `extra` parameter for structured data:

```python
logger.info(
    "Agent completed task",
    extra={
        "agent": "implementer",
        "task_id": task.id,
        "duration_ms": elapsed,
    },
)
```

## Never Log Secrets
```python
# Forbidden
logger.debug(f"API key: {api_key}")
logger.info(f"Auth header: {auth}")

# Correct
logger.debug("API key configured: %s", bool(api_key))
logger.info("Auth configured", extra={"has_auth": bool(auth)})
```

## Async-Safe Logging
Python's logging module is thread-safe and async-safe:

```python
async def process_item(item: Item) -> Result:
    logger.debug("Processing item", extra={"item_id": item.id})
    result = await _process(item)
    logger.info("Item processed", extra={"item_id": item.id, "status": result.status})
    return result
```

## Exception Logging
Use `logger.exception()` inside except blocks:

```python
try:
    await risky_operation()
except OperationError:
    logger.exception("Operation failed")
    raise
```

## Performance Logging
Log timing for critical operations:

```python
import time

start = time.perf_counter()
result = await expensive_operation()
elapsed = (time.perf_counter() - start) * 1000
logger.info("Operation completed", extra={"duration_ms": elapsed})
```

## Django Request Logging
For request/response logging:

```python
async def api_view(request: HttpRequest) -> JsonResponse:
    logger.info(
        "Request received",
        extra={
            "method": request.method,
            "path": request.path,
            "user": str(request.user),
        },
    )
    # ... process
```
