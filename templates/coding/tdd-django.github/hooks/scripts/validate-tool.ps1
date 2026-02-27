$ErrorActionPreference = "Stop"

# PreToolUse hook — validates tool usage for async Django TDD projects.
# Blocks dangerous commands, direct DB modifications outside migrations,
# sync HTTP libraries, and flags sync_to_async misuse.
#
# VS Code canonical format: returns hookSpecificOutput.permissionDecision

function Write-Deny {
    param([string]$Reason)
    @{
        hookSpecificOutput = @{
            permissionDecision = "deny"
            permissionDecisionReason = $Reason
        }
    } | ConvertTo-Json -Depth 3 -Compress
    exit 0
}

function Write-Ask {
    param([string]$Reason)
    @{
        hookSpecificOutput = @{
            permissionDecision = "ask"
            permissionDecisionReason = $Reason
        }
    } | ConvertTo-Json -Depth 3 -Compress
    exit 0
}

function Write-Allow {
    @{
        hookSpecificOutput = @{
            permissionDecision = "allow"
        }
    } | ConvertTo-Json -Depth 3 -Compress
    exit 0
}

# Read and parse stdin
try {
    $StdinData = $input | ConvertFrom-Json
    $ToolName = if ($StdinData.tool_name) { $StdinData.tool_name } else { $StdinData.toolName }
} catch {
    Write-Allow
}

if ([string]::IsNullOrEmpty($ToolName)) {
    Write-Allow
}

# Extract command text for terminal tools
$CommandText = ""
if ($ToolName -in @("execute", "bash", "run_in_terminal")) {
    try {
        $ToolInput = if ($StdinData.tool_input) { $StdinData.tool_input } else { $StdinData.toolInput }
        if ($ToolInput.command) { $CommandText = $ToolInput.command }
        elseif ($ToolInput.input) { $CommandText = $ToolInput.input }
    } catch {
        $CommandText = ""
    }
}

# Extract file content for edit tools
$FileContent = ""
$FilePath = ""
if ($ToolName -in @("edit", "create", "replace_string_in_file", "create_file", "insert")) {
    try {
        $ToolInput = if ($StdinData.tool_input) { $StdinData.tool_input } else { $StdinData.toolInput }
        if ($ToolInput.content) { $FileContent = $ToolInput.content }
        elseif ($ToolInput.newString) { $FileContent = $ToolInput.newString }
        elseif ($ToolInput.text) { $FileContent = $ToolInput.text }
        if ($ToolInput.filePath) { $FilePath = $ToolInput.filePath }
        elseif ($ToolInput.path) { $FilePath = $ToolInput.path }
    } catch {
        $FileContent = ""
    }
}

$LowerCmd = $CommandText.ToLower()
$LowerContent = $FileContent.ToLower()

# 1. Block dangerous system commands
$DangerousPatterns = @(
    "rm -rf /",
    "rm -rf /*",
    "rm -rf ~",
    "rm -rf .",
    "mkfs",
    "dd if=/dev/zero",
    "dd if=/dev/random",
    "chmod -R 777 /",
    "--no-preserve-root",
    "> /dev/sda"
)

if (-not [string]::IsNullOrEmpty($LowerCmd)) {
    foreach ($Pattern in $DangerousPatterns) {
        if ($LowerCmd.Contains($Pattern)) {
            Write-Deny "Destructive command blocked: matched '$Pattern'"
        }
    }
}

# 2. Block dangerous SQL / Django management commands
$SqlDangerPatterns = @("drop table", "drop database", "truncate table")

foreach ($Pattern in $SqlDangerPatterns) {
    if ($LowerCmd.Contains($Pattern) -or $LowerContent.Contains($Pattern)) {
        Write-Deny "Dangerous SQL blocked: matched '$Pattern'"
    }
}

# DELETE FROM without WHERE
if ($LowerCmd -match "delete\s+from" -and $LowerCmd -notmatch "where") {
    Write-Deny "DELETE FROM without WHERE clause is not allowed"
}
if ($LowerContent -match "delete\s+from" -and $LowerContent -notmatch "where") {
    Write-Deny "DELETE FROM without WHERE clause in file content"
}

# manage.py flush / reset_db
if ($LowerCmd.Contains("manage.py flush") -or $LowerCmd.Contains("manage.py reset_db")) {
    Write-Deny "manage.py flush/reset_db blocked — use migrations for data changes"
}

# 3. Block direct database modifications outside migrations
if (-not [string]::IsNullOrEmpty($FileContent) -and $FilePath -notmatch "/migrations/") {
    if ($LowerContent -match "(cursor\s*\.\s*execute|connection\s*\.\s*cursor|raw\s*\()") {
        Write-Ask "Direct SQL detected outside migrations — prefer Django ORM or put raw SQL in a migration"
    }
}

# 4. Warn on sync_to_async usage
if ($LowerContent.Contains("sync_to_async")) {
    Write-Ask "sync_to_async detected — this should be a last resort in async Django. Prefer native async ORM and async-compatible libraries."
}
if ($LowerCmd.Contains("sync_to_async")) {
    Write-Ask "sync_to_async in command — prefer async-native approaches"
}

# 5. Block requests library (should use httpx in async Django)
if ($LowerContent -match "(import\s+requests|from\s+requests\s+import)") {
    Write-Deny "Use httpx instead of requests for async Django projects"
}
if ($LowerCmd.Contains("pip install requests") -and -not $LowerCmd.Contains("pip install requests-")) {
    Write-Ask "Consider using httpx instead of requests for async Django compatibility"
}

# Default: allow
Write-Allow
