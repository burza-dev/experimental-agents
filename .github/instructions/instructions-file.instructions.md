---
applyTo: "**/*.instructions.md"
excludeAgent: "code-review"
---

# Instruction File Rules

## File Structure

Instruction files MUST have:
1. YAML frontmatter with `applyTo` pattern
2. Markdown body with instructions

```markdown
---
applyTo: "glob-pattern"
---

# Instruction Title

Instructions for matched files...
```

## YAML Frontmatter Requirements

### Core Properties
- `applyTo` - Glob pattern(s) for matching files (recommended; if omitted, instructions can be manually attached in Chat but won't auto-apply)

### Optional Properties
- `excludeAgent` - `"code-review"` or `"coding-agent"`
- `name` - Display name shown in UI (defaults to filename)
- `description` - Short description shown on hover in Chat view

## Glob Pattern Syntax

| Pattern | Matches |
|---------|---------|
| `*.py` | Python files in current directory |
| `**/*.py` | Python files recursively |
| `src/**/*.py` | Python files under src/ |
| `**/*.{ts,tsx}` | TypeScript and TSX files |
| `**/test_*.py` | Test files matching pattern |

Multiple patterns: `"**/*.ts,**/*.tsx,**/*.js"`

## File Location

Instructions files must be in:
- `.github/instructions/` - Required base directory
- `.github/instructions/subdirectory/` - Optional organization

Files MUST end with `.instructions.md`.

## Instruction Layering

Multiple instruction files CAN match the same file. When this happens:
- Instructions are **combined/layered** together
- More specific patterns take precedence over general patterns
- All matching instructions apply to the file

### Example: Layered Instructions

```
**/*.md                 → Base markdown rules (line length, headings)
**/*.agent.md           → Agent-specific rules (YAML properties, structure)
**/agents/test-*.md     → Test agent specific rules
```

When editing `agents/test-runner.agent.md`, ALL three instruction files apply:
1. `markdown.instructions.md` (base formatting)
2. `agent-definition.instructions.md` (agent structure)
3. `test-agents.instructions.md` (test-specific rules)

More specific rules override general rules when they conflict.

## Naming Conventions

Use descriptive names matching the target:
- ✅ `python.instructions.md`
- ✅ `react-component.instructions.md`
- ✅ `api-routes.instructions.md`
- ❌ `instructions.md` (too generic)
- ❌ `rules.instructions.md` (not descriptive)

## Content Structure

### Recommended Sections
1. Purpose statement
2. Formatting rules
3. Code examples (good vs bad)
4. Forbidden patterns
5. Quality checklist

### Code Examples
Always use syntax highlighting:

```markdown
## Good Pattern
```python
def calculate_total(items: list[Item]) -> Decimal:
    """Calculate the total price of items."""
    return sum(item.price for item in items)
```

## Bad Pattern
```python
def calc(x):  # Missing type hints, vague name
    return sum(i.p for i in x)
```
```

## Forbidden Patterns

- Overlapping glob patterns that create **conflicting or contradictory rules**
- Unintentional pattern overlaps (intentional layering for complementary rules is encouraged)
- Instructions too generic for the file type
- Rules that belong in `copilot-instructions.md`
- Missing examples for complex rules

## Quality Standards

- Pattern must accurately match intended files
- Instructions must be relevant to matched file types
- Include both positive and negative examples
- List forbidden patterns explicitly
- File content must be under 30,000 characters
