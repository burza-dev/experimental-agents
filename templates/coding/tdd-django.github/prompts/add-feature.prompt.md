---
name: add-feature
description: Add a new feature with full TDD workflow
agent: manager
argument-hint: "Describe the feature to add"
---

# Add Feature

Implement a new feature using the TDD Red-Green-Refactor workflow with async Django support.

## Requirements
- Feature: {{feature}}
- Scope: {{scope}}

## Variables
- `{{feature}}` — Short description of the feature to implement (e.g., "user authentication with OAuth2")
- `{{scope}}` — Django apps or modules affected (e.g., "accounts, api")

## Async Django Considerations
- Use async views and async ORM methods (`aget`, `acreate`, `afilter`, etc.)
- Validate concurrency safety for shared state
- Use `sync_to_async` / `async_to_sync` wrappers only when necessary

## Workflow (TDD-First)
1. Architect creates test plan and acceptance criteria
2. TDD test writer creates failing tests first (RED)
3. Implementer writes minimal async code to pass tests (GREEN)
4. Implementer refactors for clarity and performance (REFACTOR)
5. Coverage test writer closes gaps
6. E2E specialist adds browser tests (if UI)
7. Code reviewer validates quality and async patterns
8. Test reviewer validates test quality

## Quality Gates
- 75% unit + integration coverage
- All linting passes (ruff)
- All type checks pass (mypy --strict)
- Complexity grade A (src), B (tests)
- No sync ORM calls in async views
