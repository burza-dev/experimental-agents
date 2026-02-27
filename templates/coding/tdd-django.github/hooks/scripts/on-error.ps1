$ErrorActionPreference = "Stop"

# Error hook — logs error details and suggests recovery actions
# for common Django errors (migration conflicts, import errors, test failures).
#
# Note: errorOccurred has no VS Code canonical equivalent, but this script
# handles both formats for portability.

$LogDir = if ($env:AGENT_LOG_DIR) { $env:AGENT_LOG_DIR } else { "./logs" }
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

try {
    $StdinData = $input | ConvertFrom-Json
    $ErrorMsg = if ($StdinData.error) { $StdinData.error }
                elseif ($StdinData.message) { $StdinData.message }
                else { "unknown error" }
    $ErrorStack = if ($StdinData.stack) { $StdinData.stack } else { "" }
} catch {
    $ErrorMsg = "unknown error"
    $ErrorStack = ""
}

# Log the error
$LogEntry = "[$Timestamp] ERROR: $ErrorMsg"
Add-Content -Path "$LogDir/errors.log" -Value $LogEntry
if (-not [string]::IsNullOrEmpty($ErrorStack)) {
    Add-Content -Path "$LogDir/errors.log" -Value "  STACK: $ErrorStack"
}

# Suggest recovery actions for common Django errors
$LowerError = "$ErrorMsg $ErrorStack".ToLower()
$Suggestion = ""

if ($LowerError -match "conflicting migrations|inconsistentmigrationhistory") {
    $Suggestion = "Migration conflict detected. Try: python manage.py makemigrations --merge"
}
elseif ($LowerError -match "no such table|relation.*does not exist") {
    $Suggestion = "Missing table. Run: python manage.py migrate"
}
elseif ($LowerError -match "importerror|modulenotfounderror") {
    $Suggestion = "Import error. Check: 1) Package installed in venv 2) PYTHONPATH correct 3) __init__.py exists"
}
elseif ($LowerError -match "assert.*failed|test.*failed") {
    $Suggestion = "Test failure. Run the failing test in isolation: pytest <test_file>::<test_name> -vvs"
}
elseif ($LowerError -match "operationalerror" -and $LowerError -match "database") {
    $Suggestion = "Database connection error. Check: 1) DB service running 2) DATABASE_URL correct 3) Credentials valid"
}
elseif ($LowerError -match "synchronousonlyoperation") {
    $Suggestion = "Sync operation in async context. Use async ORM methods or wrap with sync_to_async as last resort."
}
elseif ($LowerError -match "permission.*denied") {
    $Suggestion = "Permission denied. Check file/directory permissions and user privileges."
}
elseif ($LowerError -match "address already in use") {
    $Suggestion = "Port in use. Find process: lsof -i :<port> | kill it, or use a different port."
}

# Build response
$Response = @{ status = "logged"; error = $ErrorMsg }
if (-not [string]::IsNullOrEmpty($Suggestion)) {
    $Response["suggestion"] = $Suggestion
}

$Response | ConvertTo-Json -Compress
