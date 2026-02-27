---
applyTo: "**/*.md"
---

# Markdown File Rules

> **Base Layer**: These rules apply to ALL `.md` files. More specific instruction files 
> (e.g., `agent-definition.instructions.md` for `.agent.md` files) add layers of additional 
> rules for their file types.

## General Formatting

- Use proper heading hierarchy: `#` → `##` → `###`
- Keep lines under 100 characters when practical
- One blank line before headings
- One blank line between sections

## Headings

```markdown
# Document Title (only one per file)

## Main Section

### Subsection

#### Sub-subsection (use sparingly)
```

Do NOT skip levels:
- ❌ `#` followed by `###`
- ✅ `#` followed by `##`

## Code Blocks

Always specify the language:

```markdown
```python
def hello():
    print("Hello, world!")
```
```

Common language identifiers:
- `python`, `javascript`, `typescript`, `bash`, `json`, `yaml`, `markdown`

## Lists

### Bullet Lists
```markdown
- First item
- Second item
  - Nested item
  - Another nested
- Third item
```

### Numbered Lists
```markdown
1. First step
2. Second step
3. Third step
```

Use numbered lists for sequential steps, bullet lists for unordered items.

## Tables

```markdown
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |
```

- Align columns consistently
- Keep cell content concise
- Use header row always

## Links

```markdown
[Link text](url)
[Internal link](path/to/file.md)
[Heading link](#heading-name)
```

## Images

```markdown
![Alt text](path/to/image.png)
![Logo](./assets/logo.svg "Optional title")
```

Always provide meaningful alt text for accessibility.

## Blockquotes

```markdown
> This is a blockquote.
> It can span multiple lines.

> Nested blockquotes:
>> Are also possible.
```

Use blockquotes for:
- Quotations from external sources
- Important callouts
- Notes or warnings

## YAML Frontmatter

When present, must be at the very start:

```markdown
---
property: value
---

# Document Title
```

## Forbidden Patterns

- Multiple H1 headings
- Skipped heading levels
- Code blocks without language
- Broken links
- Trailing whitespace
- Tabs outside code blocks (use spaces)
  - Exception: Tabs are allowed in code blocks for Makefiles and Go code

## Quality Standards

- Valid Markdown syntax
- Consistent formatting throughout
- No broken links
- Proper code block highlighting
- Clear heading structure
- File content must be under 30,000 characters
