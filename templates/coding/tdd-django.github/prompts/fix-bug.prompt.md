---
name: fix-bug
description: Fix a bug with a TDD regression test
agent: manager
argument-hint: "Describe the bug to fix"
---

# Fix Bug

Fix a bug using TDD — write a failing regression test first, then fix the code.

## Requirements
- Bug description: {{bug_description}}
- Expected behavior: {{expected}}
- Actual behavior: {{actual}}

## Variables
- `{{bug_description}}` — Clear description of the bug behavior
- `{{expected}}` — Expected correct behavior
- `{{actual}}` — Actual (buggy) behavior observed

## Async Django Considerations
- Check for async/sync boundary issues (e.g., sync ORM in async view)
- Verify `asyncio` event loop handling if concurrency is involved
- Test with `pytest-asyncio` for async code paths

## Workflow (TDD-First)
1. Architect analyzes bug and identifies root cause
2. TDD test writer creates failing test reproducing the bug (RED)
3. Implementer writes minimal fix to pass the test (GREEN)
4. Implementer refactors if needed (REFACTOR)
5. Coverage test writer ensures coverage maintained
6. Code reviewer validates fix doesn't introduce regressions

## Deliverables
- Regression test proving bug is fixed
- Minimal code change fixing the issue
- Updated documentation if API changed

## Quality Gates
- 75% unit + integration coverage
- All linting passes (ruff)
- All type checks pass (mypy --strict)
- Complexity grade A (src), B (tests)
