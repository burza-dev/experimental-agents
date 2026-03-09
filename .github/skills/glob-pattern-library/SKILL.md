---
name: glob-pattern-library
description: 'Reference library of glob patterns for GitHub Copilot instruction files. Use when writing applyTo patterns in .instructions.md files, or when debugging why instructions apply to wrong files. Covers common patterns by ecosystem, exclusions, and anti-patterns.'
---

# Glob Pattern Library

Tested glob patterns for `applyTo` fields in `.instructions.md` files.

## Pattern Syntax Quick Reference

| Syntax | Meaning | Example |
|--------|---------|---------|
| `*` | Any characters in one segment | `*.ts` matches `app.ts` |
| `**` | Any number of path segments | `**/*.ts` matches `src/app.ts` |
| `?` | Single character | `?.ts` matches `a.ts` |
| `{a,b}` | Alternatives (MUST quote in YAML) | `"**/*.{ts,tsx}"` |
| `[abc]` | Character class | `[Rr]eadme.md` |
| `!` | Negation (when supported) | `!**/node_modules/**` |

**YAML quoting rule**: Patterns containing `{`, `}`, `[`, `]`, `#`, or `:` MUST be quoted.

## Patterns by Ecosystem

### JavaScript / TypeScript

| Purpose | Pattern |
|---------|---------|
| All TypeScript | `"**/*.{ts,tsx}"` |
| All JavaScript | `"**/*.{js,jsx}"` |
| All JS/TS | `"**/*.{js,jsx,ts,tsx}"` |
| Test files (Jest/Vitest) | `"**/*.{test,spec}.{ts,tsx,js,jsx}"` |
| Test directories | `"**/__tests__/**"` |
| React components | `"**/components/**/*.{tsx,jsx}"` |
| Next.js pages | `"**/app/**/page.{ts,tsx}"` |
| Next.js API routes | `"**/app/api/**/*.ts"` |
| Config files | `"*.config.{ts,js,mjs,cjs}"` |
| Package manifests | `"**/package.json"` |

### Python

| Purpose | Pattern |
|---------|---------|
| All Python | `**/*.py` |
| Test files | `"**/test_*.py"` |
| Test files (pytest) | `"**/*_test.py"` |
| Django views | `"**/views.py"` |
| Django models | `"**/models.py"` |
| FastAPI routes | `"**/routers/**/*.py"` |
| Config | `"**/{settings,config}.py"` |
| Requirements | `"**/requirements*.txt"` |

### Go

| Purpose | Pattern |
|---------|---------|
| All Go | `**/*.go` |
| Test files | `**/*_test.go` |
| Go modules | `**/go.{mod,sum}` |

### Rust

| Purpose | Pattern |
|---------|---------|
| All Rust | `**/*.rs` |
| Cargo config | `**/Cargo.toml` |

### C# / .NET

| Purpose | Pattern |
|---------|---------|
| All C# | `**/*.cs` |
| Test projects | `"**/*.Tests/**/*.cs"` |
| Project files | `"**/*.{csproj,sln}"` |
| Razor views | `"**/*.{cshtml,razor}"` |

### Java / Kotlin

| Purpose | Pattern |
|---------|---------|
| All Java | `**/*.java` |
| All Kotlin | `"**/*.{kt,kts}"` |
| Test files | `"**/src/test/**/*.java"` |
| Build config | `"**/{build.gradle,pom.xml}"` |

### Infrastructure & DevOps

| Purpose | Pattern |
|---------|---------|
| Terraform | `**/*.tf` |
| Bicep | `**/*.bicep` |
| Docker | `"**/Dockerfile*"` |
| Docker Compose | `"**/docker-compose*.{yml,yaml}"` |
| Kubernetes | `"**/k8s/**/*.{yml,yaml}"` |
| GitHub Actions | `".github/workflows/**/*.{yml,yaml}"` |
| CI configs | `"**/.{github,gitlab-ci,circleci}/**"` |

### Documentation & Config

| Purpose | Pattern |
|---------|---------|
| All Markdown | `**/*.md` |
| All YAML | `"**/*.{yml,yaml}"` |
| All JSON | `**/*.json` |
| All TOML | `**/*.toml` |
| Environment files | `"**/.env*"` |
| Editor config | `"**/.{editorconfig,prettierrc,eslintrc}*"` |

### Copilot Configuration Files

| Purpose | Pattern |
|---------|---------|
| Agent definitions | `"**/*.agent.md"` |
| Instruction files | `"**/*.instructions.md"` |
| Prompt files | `"**/*.prompt.md"` |
| Skill files | `"**/.github/skills/**/SKILL.md"` |
| Skills (any location) | `"**/SKILL.md"` |
| Hooks config | `"**/hooks.json"` |
| Copilot instructions | `"**/copilot-instructions.md"` |

## Anti-Patterns (Avoid These)

| Bad Pattern | Problem | Better Pattern |
|-------------|---------|---------------|
| `**/*` | Matches ALL files | Use specific extensions |
| `*.ts` | Only matches root directory | `**/*.ts` for recursive |
| `**/*.{ts,tsx,js,jsx,json,md,css,html}` | Too broad, many unrelated files | Split into separate instruction files |
| `src/**` | Matches everything in src/ | `src/**/*.ts` for specific types |
| `test/**` | May miss colocated tests | `"**/*.{test,spec}.*"` catches both |
| `**/*.test.ts` | Misses `.spec.ts` files | `"**/*.{test,spec}.ts"` |
| Unquoted `**/*.{a,b}` | YAML parse error | `"**/*.{a,b}"` (quote it) |

## Pattern Composition Tips

1. **One instruction per concern**: Create separate instruction files for testing vs implementation code
2. **Specificity wins**: `src/api/**/*.ts` is better than `**/*.ts` when instructions only apply to API code
3. **Test pattern matching**: Run `find . -path './pattern'` or `ls pattern` to verify matches
4. **Consider exclusions**: Use `excludeAgent` in frontmatter rather than complex negative globs
5. **Document intent**: Add `description` to explain what the pattern targets and why
