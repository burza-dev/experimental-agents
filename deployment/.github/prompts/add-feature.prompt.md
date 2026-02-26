---
name: add-feature
description: Add a new feature with full TDD workflow
---

# Add Feature

Implement a new feature using TDD workflow.

## Requirements
- Feature: {{feature}}
- Scope: {{scope}}

## Workflow
1. Architect creates test plan and acceptance criteria
2. TDD test writer creates failing tests (RED)
3. Implementer writes code to pass tests (GREEN)
4. Implementer refactors if needed (REFACTOR)
5. Coverage test writer closes gaps
6. E2E specialist adds browser tests (if UI)
7. Code reviewer validates quality
8. Test reviewer validates test quality

## Quality Gates
- 75% unit + integration coverage
- All linting passes (ruff)
- All type checks pass (mypy --strict)
- Complexity grade A (src), B (tests)
