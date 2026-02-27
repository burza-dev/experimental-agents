---
name: onboard-project
description: Create complete GitHub Copilot agent configuration for a target project
---

# Onboard Project to GitHub Copilot

Create a complete set of agent configurations for a project.

## Target Project
{{project_path}}

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{project_path}}` | Yes | path | Absolute path to the target project directory to onboard |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## Scope
Create the following for the target project:
- [ ] `copilot-instructions.md` - Repository-wide instructions
- [ ] Agent definitions for project-specific workflows
- [ ] Path-specific instructions for file types in the project
- [ ] Reusable prompts for common development tasks

## Workflow

1. **Research Phase**
   - Analyze project structure and layout
   - Identify tech stack (languages, frameworks, tools)
   - Discover build and test processes
   - Note coding conventions and patterns
   - **Check for existing AI config files**: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, or existing `.github/copilot-instructions.md` — incorporate their guidance if present

   **Research Methods:**
   | What to Find | Where to Look | How to Verify |
   |--------------|---------------|---------------|
   | Languages used | File extensions (`.ts`, `.py`, `.go`) | `find . -type f -name "*.*" \| sed 's/.*\.//' \| sort \| uniq -c` |
   | Package manager | `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml` | File exists at root |
   | Build commands | `package.json` scripts, `Makefile`, CI configs | Read and test commands |
   | Test framework | Test file patterns, config files (`jest.config.js`, `pytest.ini`) | Run test command |
   | Linter/formatter | `.eslintrc`, `.prettierrc`, `pyproject.toml` | Run lint command |
   | CI/CD | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` | Read pipeline steps |
   | Coding style | Existing code, `CONTRIBUTING.md`, style configs | Compare multiple files |

2. **Create Repository Instructions**
   - Document project overview
   - Map repository structure
   - List build, test, lint commands
   - Define coding standards and quality gates

3. **Create Agent Definitions**
   - Identify roles needed for the project
   - Create focused agents for each role
   - Configure tools and handoffs appropriately
   - Incorporate TDD workflow where applicable — developer agents should recommend writing tests before implementation and include test verification steps

4. **Create Path-Specific Instructions**
   - Instructions for each major file type
   - Framework-specific guidelines
   - Test file conventions

5. **Create Prompts**
   - Common development workflows
   - Project-specific tasks
   - Review and maintenance prompts

6. **Quality Gates and Review**
   - Run self-review on all created configuration files
   - Validate YAML/JSON syntax for every file
   - Verify no overlapping agent responsibilities
   - Confirm all file paths and cross-references are correct
   - Each *-reviewer validates corresponding files
   - If CHANGES REQUIRED: developer fixes → same reviewer re-reviews (loop until APPROVED)

## Deliverables

```
{{project_path}}/.github/
├── copilot-instructions.md
├── agents/
│   ├── manager.agent.md
│   └── [role].agent.md
├── instructions/
│   └── [filetype].instructions.md
└── prompts/
    └── [task].prompt.md
```

## Error Handling

- If project path does not exist: Report error and request valid path
- If project has no clear structure: Document what exists and ask for clarification on conventions
- If build/test commands fail: Document commands as-found but note they need verification
- If no existing conventions found: Create sensible defaults based on tech stack best practices

## Success Criteria

- [ ] All configuration files have valid YAML/JSON frontmatter
- [ ] `copilot-instructions.md` documents actual project structure
- [ ] Build/test/lint commands verified working (run them to confirm)
- [ ] At least one agent definition created
- [ ] Instructions created for primary language file types
- [ ] No overlapping agent responsibilities
- [ ] All file paths are correct and files exist

## Command Testing

"Commands have been tested" means:
1. Each command was executed in the project directory
2. The command completed without errors (exit code 0)
3. The output was verified to match expected behavior
4. If a command fails, document the failure and expected fix

## Quality Standards

- All YAML frontmatter is valid
- Descriptions are specific and accurate
- Tools lists are minimal but sufficient
- Instructions are actionable
- Commands have been tested
