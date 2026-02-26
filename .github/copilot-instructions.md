# Copilot Instructions for agents-instructions

## Project Overview

This project (`agents-instructions`) develops **portable coding agent instructions** - reusable agent definitions, prompts, and configuration files that can be adopted by other projects. This is a **documentation/configuration project**, not a software application.

## Multi-Agent Workflow

This project uses specialized agents for documentation development.

### Available Agents

| Agent | Purpose |
|-------|---------|
| `manager` | Orchestrates documentation workflow, validates completion |
| `architect` | Plans documentation structure and organization |
| `doc-writer` | Writes and updates documentation content |
| `doc-reviewer` | Reviews documentation quality and accuracy |
| `researcher` | Researches best practices and existing patterns |

### Documentation Workflow

1. **Plan** → Architect creates documentation structure plan
2. **Research** → Researcher gathers best practices and patterns
3. **Write** → Doc Writer creates or updates content
4. **Review** → Doc Reviewer validates quality
5. **Validate** → Manager confirms all quality gates pass

### Organization

- Agents are defined in `.github/agents/`
- Path-specific instructions in `.github/instructions/`
- Reusable prompts in `.github/prompts/`

## Critical Rules - Read First

**NEVER** finish a task early or leave work incomplete. You **MUST**:

1. **Complete every requirement** specified in the task before marking it done
2. **Write complete content** - no placeholders, stubs, or TODO comments
3. **Verify accuracy** - all documentation must be accurate and tested
4. **Ignore time limits** - quality trumps speed; take as long as needed
5. **Fix all issues** - do not leave known problems or inconsistencies
6. **Listen to user requests** - user requests must be addressed
7. **Strive for excellence** - analyze if everything was done well before finishing
8. **Consolidate and reuse** - avoid duplication, refactor similar content
9. **Refactor and reuse** - always avoid adding new code, when encountering similar functions refactor and reduce amount of code without reducing functionality, you must focus on providing value to the project while keeping codebase small and maintainable

## Quality Standards

### Markdown Files (Mandatory)

All Markdown files **MUST** follow these standards:

- Clear, hierarchical heading structure (# → ## → ###)
- Proper code block syntax highlighting
- No broken links
- Consistent formatting throughout
- Valid Markdown syntax
- Line length ≤ 100 characters preferred

### YAML/TOML Files (Mandatory)

- Use 2 spaces for indentation (no tabs)
- No trailing whitespace
- Consistent key naming (snake_case)
- Valid syntax

### Writing Style

- Clear and concise language
- Present tense for current behavior
- Active voice preferred over passive
- Technical accuracy is paramount
- Keep paragraphs short and focused

### Documentation Requirements

- All instructions must have clear purpose statements
- Include practical examples where helpful
- Cross-reference related documents
- Keep all documentation in sync

## Project Structure

```
agents-instructions/
├── .github/                  # Internal config (doc-focused agents for this repo)
│   ├── agents/               # Documentation workflow agents
│   │   ├── architect.agent.md
│   │   ├── doc-reviewer.agent.md
│   │   ├── doc-writer.agent.md
│   │   ├── manager.agent.md
│   │   └── researcher.agent.md
│   ├── instructions/         # Path-specific instructions
│   │   ├── config.instructions.md
│   │   ├── documentation.instructions.md
│   │   └── shell.instructions.md
│   ├── prompts/              # Reusable prompts
│   │   ├── add-feature.prompt.md
│   │   └── fix-bug.prompt.md
│   └── copilot-instructions.md
├── deployment/               # Deployment templates (for other projects)
└── README.md
```

## Workflow Guidelines

### Before Writing Documentation

1. Read the full task description and requirements
2. Understand the existing documentation structure
3. Plan your approach before writing
4. Check for existing content you can reuse or reference

### While Writing

1. Follow established patterns and conventions
2. Keep content organized and well-structured
3. Cross-reference related documentation
4. Validate all examples and code snippets

### Before Completing a Task

- All content is written and complete
- Markdown syntax is valid
- All links work
- Content is accurate and up-to-date
- Related documentation is updated

## Prohibited Practices

**NEVER do any of these:**

1. Leave incomplete sections with TODO/FIXME comments
2. Create placeholder content
3. Leave broken links
4. Create inconsistent formatting
5. Duplicate existing content without reason
6. Leave outdated information

## Agent Behavior

When working on tasks:

1. **Be thorough** - complete every detail, not just the main content
2. **Be critical** - review your own work for issues before finishing
3. **Be persistent** - keep working until ALL requirements are met
4. **Be honest** - if you cannot complete something, explain why clearly

**Remember: A task is NOT complete until:**
- All documentation is written and accurate
- All formatting is correct
- All links are valid
- Related documents are updated

## References

- [Markdown Guide](https://www.markdownguide.org/)
- [YAML Specification](https://yaml.org/spec/)
- [TOML Specification](https://toml.io/en/)
