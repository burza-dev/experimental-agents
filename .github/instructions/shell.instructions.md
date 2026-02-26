---
applyTo: "**/*.{sh,bash}"
---

# Shell Script Rules

## Shebang
Always use explicit bash with immediate failure:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

## Variable Quoting
Always quote variables to handle spaces:

```bash
# Correct
file_path="$HOME/projects/my-project"
echo "Processing: $file_path"

# Wrong
file_path=$HOME/projects/my-project  # May break with spaces
echo Processing: $file_path       # May break with spaces
```

## Command Substitution
Use `$()` instead of backticks:

```bash
# Correct
current_date=$(date +%Y-%m-%d)

# Wrong (legacy)
current_date=`date +%Y-%m-%d`
```

## Conditional Tests
Use `[[ ]]` for conditionals:

```bash
# Correct
if [[ -f "$config_file" ]]; then
    source "$config_file"
fi

# Also correct for simple existence
[[ -d "$dir" ]] || mkdir -p "$dir"
```

## Functions
Define functions with clear error handling:

```bash
log_info() {
    echo "[INFO] $(date +%H:%M:%S) $*"
}

log_error() {
    echo "[ERROR] $(date +%H:%M:%S) $*" >&2
}

cleanup() {
    log_info "Cleaning up..."
    rm -rf "$tmp_dir"
}
trap cleanup EXIT
```

## Error Handling
Check command results explicitly:

```bash
if ! uv sync; then
    log_error "Failed to sync dependencies"
    exit 1
fi
```

## Script Arguments
Parse arguments properly:

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 [-v] [-h] <target>"
    exit 1
}

verbose=false
while getopts "vh" opt; do
    case $opt in
        v) verbose=true ;;
        h) usage ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

target="${1:-}"
[[ -n "$target" ]] || usage
```

## Quality Commands
Scripts for validation:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Validate shell scripts
shellcheck script.sh

# Check for common issues
# Add project-specific validation here
```

## Forbidden Patterns
- Missing `set -euo pipefail`
- Unquoted variables
- Backticks for command substitution
- `[ ]` instead of `[[ ]]`
- Hardcoded paths without variables
- Missing error handling
