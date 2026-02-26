---
name: new-endpoint
description: Create a new Django async API endpoint with tests
---

# New API Endpoint

Create a new async Django API endpoint.

## Requirements
- Endpoint path: {{path}}
- HTTP methods: {{methods}}
- Description: {{description}}

## Workflow
1. Architect plans test cases and async patterns
2. TDD test writer creates failing tests
3. Implementer creates async view with Pydantic validation
4. Coverage test writer closes gaps to 75%+
5. Code reviewer validates async patterns and security

## Includes
- Async view function
- Pydantic request/response models
- URL pattern registration
- Unit tests with all HTTP methods
- Integration tests with database
