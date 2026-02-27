---
name: new-endpoint
description: Create a new Django async API endpoint with tests
agent: manager
argument-hint: "Describe the API endpoint to create"
---

# New API Endpoint

Create a new async Django API endpoint using the TDD Red-Green-Refactor workflow.

## Requirements
- Endpoint path: {{path}}
- HTTP methods: {{methods}}
- Description: {{endpoint_description}}

## Variables
- `{{path}}` — URL path for the endpoint (e.g., "/api/v1/users/")
- `{{methods}}` — HTTP methods to support (e.g., "GET, POST, PUT")
- `{{endpoint_description}}` — What the endpoint does

## Async Django Considerations
- Use `async def` views with async ORM queries
- Validate Pydantic models for request/response schemas
- Handle `sync_to_async` for any third-party sync dependencies
- Return proper HTTP status codes and structured error responses

## Workflow (TDD-First)
1. Architect plans test cases and async patterns
2. TDD test writer creates failing tests for all HTTP methods (RED)
3. Implementer creates async view with Pydantic validation (GREEN)
4. Implementer refactors for clarity and async best practices (REFACTOR)
5. Coverage test writer closes gaps to 75%+
6. Code reviewer validates async patterns and security
7. If CHANGES REQUIRED: Implementer fixes → same reviewer re-reviews (loop until APPROVED)

## Includes
- Async view function
- Pydantic request/response models
- URL pattern registration
- Unit tests with all HTTP methods
- Integration tests with database
- Error response tests (400, 404, 500)

## Quality Gates
- 75% unit + integration coverage
- All linting passes (ruff)
- All type checks pass (mypy --strict)
- Complexity grade A (src), B (tests)
- No sync ORM calls in async views
