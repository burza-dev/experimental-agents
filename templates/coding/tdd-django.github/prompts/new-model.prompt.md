---
name: new-model
description: Create a new Django model with async methods
agent: manager
argument-hint: "Describe the Django model to create"
---

# New Django Model

Create a new async-compatible Django model using the TDD Red-Green-Refactor workflow.

## Requirements
- Model name: {{model_name}}
- Fields: {{fields}}
- Description: {{model_description}}

## Variables
- `{{model_name}}` — PascalCase Django model name (e.g., "UserProfile")
- `{{fields}}` — Model fields with types (e.g., "title: CharField(max_length=200), created_at: DateTimeField(auto_now_add=True)")
- `{{model_description}}` — Purpose and relationships of the model

## Async Django Considerations
- Use async ORM methods (`acreate`, `aget`, `afilter`, `acount`, etc.)
- Add `__str__` and async convenience methods
- Ensure model managers support async queries
- Use `select_related` / `prefetch_related` for async query optimization

## Workflow (TDD-First)
1. Architect designs model and async method signatures
2. TDD test writer creates failing model tests (RED)
3. Implementer creates model with async methods (GREEN)
4. Implementer refactors for clarity (REFACTOR)
5. Create and validate migration
6. Coverage test writer validates coverage to 75%+

## Includes
- Model with typed fields
- Async class methods (`acreate`, `aget`, etc.)
- Migration file
- Unit tests for model methods
- Factory fixture in conftest.py

## Quality Gates
- 75% unit + integration coverage
- All linting passes (ruff)
- All type checks pass (mypy --strict)
- Complexity grade A (src), B (tests)
