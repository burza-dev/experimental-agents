---
name: security-patterns
description: Security best practices for Django web applications. Apply when implementing authentication, input handling, file operations, or external API calls.
---

# Security Patterns

## Input Validation
- Always use Pydantic models for request validation
- Never trust user input - validate and sanitize
- Use Django's QueryDict carefully with `.get()` and defaults

```python
from pydantic import BaseModel, validator

class UserInput(BaseModel):
    name: str
    email: str
    
    @validator("email")
    def validate_email(cls, v: str) -> str:
        if "@" not in v:
            raise ValueError("Invalid email")
        return v.lower()
```

## File Operations
- Use `pathlib.Path` with `.resolve()` to prevent path traversal
- Always validate file extensions and MIME types
- Use `tmp_path` or configured upload directories, never arbitrary paths

```python
from pathlib import Path

ALLOWED_EXTENSIONS = {".txt", ".pdf", ".png"}

def safe_path(user_path: str, base_dir: Path) -> Path:
    """Resolve path safely within base directory."""
    resolved = (base_dir / user_path).resolve()
    if not resolved.is_relative_to(base_dir):
        raise ValueError("Path traversal detected")
    if resolved.suffix not in ALLOWED_EXTENSIONS:
        raise ValueError("Invalid file type")
    return resolved
```

## Secrets Management
- Never hardcode secrets in source code
- Use environment variables with `{PROJECT_PREFIX}_` prefix
- Never log secrets or include in error messages

```python
# Forbidden
api_key = "sk-abc123"  # NEVER DO THIS

# Correct
api_key = os.getenv("{PROJECT_PREFIX}_API_KEY", "")
```

## SQL Injection Prevention
- Always use Django ORM or parameterized queries
- Never use f-strings or string formatting for queries

```python
# Forbidden
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")

# Correct
await User.objects.filter(id=user_id).afirst()
```

## CSRF Protection
- Django CSRF middleware is mandatory
- Include `{% csrf_token %}` in all forms
- Use `@csrf_protect` decorator for views that need it

## Authentication
- Use Django's async authentication utilities
- Validate session tokens properly
- Implement rate limiting for login endpoints
