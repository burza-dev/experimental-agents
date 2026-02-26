---
name: pydantic-conventions
description: Pydantic v2 model conventions for your project. Apply when creating data models, DTOs, or configuration classes.
---

# Pydantic v2 Conventions

## Model Definition
Use modern Python 3.11+ type hints:

```python
from pydantic import BaseModel, Field

class AgentConfig(BaseModel):
    """Configuration for an AI agent."""
    
    name: str = Field(..., min_length=1, max_length=100)
    model: str = Field(default="{DEFAULT_MODEL}")
    temperature: float = Field(default=0.7, ge=0.0, le=2.0)
    max_tokens: int | None = Field(default=None, gt=0)
    tags: list[str] = Field(default_factory=list)
```

## Field Validation
Use Field constraints and validators:

```python
from pydantic import BaseModel, Field, field_validator

class TaskRequest(BaseModel):
    """Request to create a task."""
    
    title: str = Field(..., min_length=1, max_length=200)
    priority: int = Field(default=1, ge=1, le=5)
    
    @field_validator("title")
    @classmethod
    def title_must_not_be_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Title cannot be blank")
        return v.strip()
```

## Settings with Environment Variables
Use BaseSettings for configuration:

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class {ProjectSettings}(BaseSettings):
    """Application settings from environment."""
    
    model_config = SettingsConfigDict(
        env_prefix="{PROJECT_PREFIX}_",
        env_file=".env",
        env_file_encoding="utf-8",
    )
    
    debug: bool = False
    log_level: str = "INFO"
    openai_api_key: str | None = None
```

## Immutable Models
Use frozen=True for data that shouldn't change:

```python
class AgentResponse(BaseModel):
    """Immutable agent response."""
    
    model_config = {"frozen": True}
    
    agent: str
    content: str
    tokens_used: int
```

## JSON Serialization
Custom serialization with model_dump:

```python
response = agent.execute()
json_data = response.model_dump(mode="json", exclude_none=True)
```

## Strict Mode
Enable strict validation for APIs:

```python
class StrictInput(BaseModel):
    """Strict input validation."""
    
    model_config = {"strict": True}
    
    count: int  # Will not coerce "5" to 5
```

## Union Types
Use discriminated unions for polymorphic data:

```python
from typing import Literal

class TextMessage(BaseModel):
    type: Literal["text"] = "text"
    content: str

class ImageMessage(BaseModel):
    type: Literal["image"] = "image"
    url: str

Message = TextMessage | ImageMessage
```
