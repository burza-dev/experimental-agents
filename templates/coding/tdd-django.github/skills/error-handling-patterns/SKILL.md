---
name: error-handling-patterns
description: Consistent error handling patterns for your project. Apply when implementing error types, exception handling, or error responses.
---

# Error Handling Patterns

## Custom Exception Hierarchy
All project exceptions inherit from a base class:

```python
class {ProjectError}(Exception):
    """Base exception for all project errors."""
    
    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(message)
        self.message = message
        self.details = details or {}

class ConfigurationError({ProjectError}):
    """Raised when configuration is invalid."""
    pass

class AgentError({ProjectError}):
    """Raised when an agent operation fails."""
    pass

class NetworkError({ProjectError}):
    """Raised when network operations fail."""
    pass
```

## Error Handling in Async Code
Always use try/except with specific exceptions:

```python
import httpx

async def call_api(url: str) -> dict[str, Any]:
    """Call API with proper error handling."""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            response.raise_for_status()
            return response.json()
    except httpx.HTTPError as e:
        raise NetworkError(f"API call failed: {url}") from e
```

## Never Catch Generic Exception
```python
# Forbidden
try:
    result = await operation()
except Exception:
    pass  # Silent failure

# Correct
try:
    result = await operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise OperationError("Operation failed") from e
```

## Error Logging
Always log before raising:

```python
import logging

logger = logging.getLogger(__name__)

async def process(data: Data) -> Result:
    if not data.is_valid():
        logger.error("Invalid data received", extra={"data_id": data.id})
        raise ValidationError(f"Invalid data: {data.id}")
    return await _process_internal(data)
```

## Django Error Responses
Return consistent JSON error responses:

```python
from django.http import JsonResponse

async def api_view(request: HttpRequest) -> JsonResponse:
    try:
        result = await process_request(request)
        return JsonResponse({"data": result})
    except ValidationError as e:
        return JsonResponse({"error": str(e)}, status=400)
    except {ProjectError} as e:
        logger.exception("Internal error")
        return JsonResponse({"error": "Internal error"}, status=500)
```

## Error Context with `from`
Always preserve the original exception chain:

```python
try:
    data = await fetch_data()
except IOError as e:
    raise DataFetchError("Could not fetch data") from e
```
