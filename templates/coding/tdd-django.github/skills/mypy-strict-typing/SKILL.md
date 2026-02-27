---
name: mypy-strict-typing
description: MyPy strict mode patterns and type hint guidance. Apply to all Python code to ensure type safety.
---

# MyPy Strict Mode Patterns

## Strict Mode Command
Always run mypy with strict mode:

```bash
uv run mypy --strict src/
```

## Function Signatures
All functions must have fully typed signatures:

```python
# Forbidden
def process(data):
    return data.transform()

# Correct
def process(data: TaskData) -> ProcessedResult:
    return data.transform()
```

## Return Types
Always declare return types, including `None`:

```python
async def save_config(config: Config) -> None:
    """Save configuration to database."""
    await config.asave()
```

## Generic Types
Use proper generics with Python 3.11+ syntax:

```python
# Modern syntax (preferred)
def first_item(items: list[T]) -> T | None:
    return items[0] if items else None

# Dict, List, Set, etc.
def count_by_type(items: list[Item]) -> dict[str, int]:
    ...
```

## Optional vs Union
Use `| None` instead of `Optional`:

```python
# Preferred (Python 3.11+)
user: User | None = None

# Also acceptable
from typing import Optional
user: Optional[User] = None  # Legacy
```

## Callable Types
Type callable arguments properly:

```python
from collections.abc import Callable, Awaitable

async def with_retry(
    fn: Callable[[], Awaitable[T]],
    max_retries: int = 3,
) -> T:
    ...
```

## TypedDict for Dicts
Use TypedDict for structured dicts:

```python
from typing import TypedDict

class UserData(TypedDict):
    id: int
    name: str
    email: str | None
```

## Protocol for Duck Typing
Use Protocol for structural subtyping:

```python
from typing import Protocol

class Serializable(Protocol):
    def serialize(self) -> bytes: ...

def save(obj: Serializable) -> None:
    data = obj.serialize()
    ...
```

## Cast and Assert
Use `cast` sparingly with explanation:

```python
from typing import cast

# Use when mypy can't infer the type
result = cast(UserResponse, await api.call())
```

## Type Guards
Define custom type guards:

```python
from typing import TypeGuard

def is_valid_user(obj: object) -> TypeGuard[User]:
    return isinstance(obj, User) and obj.id is not None
```

## Forbidden Patterns
- `# type: ignore` without specific error code
- `Any` when a specific type is possible
- Untyped function parameters or return values
