---
name: new-model
description: Create a new Django model with async methods
---

# New Django Model

Create a new async-compatible Django model.

## Requirements
- Model name: {{name}}
- Fields: {{fields}}
- Description: {{description}}

## Workflow
1. Architect designs model and async method signatures
2. TDD test writer creates failing model tests
3. Implementer creates model with async methods
4. Create migration
5. Coverage test writer validates coverage

## Includes
- Model with typed fields
- Async class methods (acreate, aget, etc.)
- Migration file
- Unit tests for model methods
- Factory fixture in conftest.py
