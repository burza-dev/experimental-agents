---
name: fix-bug
description: Fix a bug with regression test
---

# Fix Bug

Fix a bug with regression test to prevent recurrence.

## Requirements
- Bug description: {{description}}
- Expected behavior: {{expected}}
- Actual behavior: {{actual}}

## Workflow
1. Architect analyzes bug and identifies root cause
2. TDD test writer creates failing test reproducing bug
3. Implementer fixes bug to pass test
4. Coverage test writer ensures coverage maintained
5. Code reviewer validates fix doesn't introduce issues

## Deliverables
- Regression test proving bug is fixed
- Minimal code change fixing the issue
- Updated documentation if API changed
