---
name: validate-configuration
description: Validate syntax and schema of agent configuration files
---

# Validate Configuration

Perform automated validation of configuration file syntax and schema compliance.

## Variables

| Variable | Required | Format | Description |
|----------|----------|--------|-------------|
| `{{config_path}}` | Yes | path | Path to the configuration file or directory to validate |
| `{{file_type}}` | No | `agent` \| `instructions` \| `prompt` \| `hooks` \| `auto` | Type of file; `auto` detects from extension |

> **Note:** Variables use `{{template}}` syntax as documentation placeholders. When using in VS Code, replace with `${input:variableName}` syntax or built-in variables like `${selection}`, `${file}`, `${workspaceFolder}`.

## Scope

This prompt performs **automated validation** checking:
- Syntax correctness (YAML/JSON parsing)
- Schema compliance (required fields, value constraints)
- Reference validity (file paths, tool names)

This differs from `review-configuration` which evaluates **subjective quality** (clarity, usefulness, best practices).

## Validation Checklist

### Agent Files (`.agent.md`)

| Check | Rule | Severity |
|-------|------|----------|
| YAML syntax | Frontmatter parses without errors | ERROR |
| `description` present | Field exists and is non-empty | ERROR |
| `description` length | Under 200 characters | ERROR |
| `tools` valid | Each tool name is a known Copilot tool | WARNING |
| Markdown body | Content exists after frontmatter | WARNING |

### Instructions Files (`.instructions.md`)

| Check | Rule | Severity |
|-------|------|----------|
| YAML syntax | Frontmatter parses without errors | ERROR |
| `applyTo` present | Field exists and is non-empty | ERROR |
| `applyTo` valid glob | Pattern uses valid glob syntax | ERROR |
| Content length | Under 30,000 characters | WARNING |
| Markdown body | Content exists after frontmatter | WARNING |

### Prompt Files (`.prompt.md`)

| Check | Rule | Severity |
|-------|------|----------|
| YAML syntax | Frontmatter parses without errors | ERROR |
| `name` present | Field exists and is non-empty | ERROR |
| `description` present | Field exists and is non-empty | ERROR |
| `name` format | Lowercase with hyphens only | WARNING |
| Variables documented | `{{var}}` placeholders have descriptions | WARNING |
| Variable syntax | Template vars use `{{name}}` or VS Code `${input:name}` consistently | WARNING |

### Hooks Files (`hooks.json`)

| Check | Rule | Severity |
|-------|------|----------|
| JSON syntax | File parses without errors | ERROR |
| `version` present | Field equals `1` | ERROR |
| Valid triggers (CLI) | Each trigger is one of: `sessionStart`, `sessionEnd`, `userPromptSubmitted`, `preToolUse`, `postToolUse`, `errorOccurred` | ERROR |
| Valid triggers (VS Code) | Each trigger is one of: `SessionStart`, `Stop`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop` | ERROR |
| Field naming format | CLI uses `toolName`/`toolArgs`; VS Code uses `tool_name`/`tool_input` | WARNING |
| Scripts exist | Referenced script files exist on disk | ERROR |
| Script permissions | Scripts are executable | WARNING |

## Validation Process

1. **Detect file type** from extension (or use `{{file_type}}` if specified)
2. **Parse syntax** - YAML frontmatter or JSON
3. **Check required fields** - Verify presence and types
4. **Validate constraints** - Length limits, format rules
5. **Verify references** - File paths, tool names, triggers
6. **Self-review** — Verify all findings are accurate, no false positives, and output format is correct

## Error Handling

### Parse Errors
```text
ERROR: Invalid YAML at line <line>
  → <error_message>
  Fix: Check for missing colons, incorrect indentation, or unquoted special characters
```

### Missing Required Fields
```text
ERROR: Missing required field '<field_name>'
  → File: <file_path>
  Fix: Add the required field to the YAML frontmatter
```

### Constraint Violations
```text
WARNING: <field_name> exceeds maximum length (<actual> > <max>)
  → File: <file_path>
  Fix: Shorten the value to meet the constraint
```

### Invalid References
```text
ERROR: Referenced file does not exist: <ref_path>
  → In: <file_path>
  Fix: Create the missing file or correct the path
```

## Success Criteria

Validation passes when:
- [ ] Zero ERROR-level issues
- [ ] All files parse successfully
- [ ] All required fields present
- [ ] All constraints satisfied
- [ ] All references resolve

Validation may pass with warnings:
- WARNING-level issues are reported but do not fail validation
- Warnings should be addressed but are not blocking

## Output Format

```markdown
## Validation Results

### {{config_path}}
Status: PASS | FAIL

#### Errors (<count>)
- ERROR: <description>

#### Warnings (<count>)
- WARNING: <description>

### Summary
- Files validated: <total>
- Passed: <passed>
- Failed: <failed>
```
