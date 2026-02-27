$ErrorActionPreference = "Stop"

# SessionStart hook — logs session start with timestamp and project context.
# VS Code canonical format (snake_case input fields).

$LogDir = if ($env:AGENT_LOG_DIR) { $env:AGENT_LOG_DIR } else { "./logs" }
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

try {
    $StdinData = $input | ConvertFrom-Json
    $SessionId = if ($StdinData.session_id) { $StdinData.session_id }
                 elseif ($StdinData.sessionId) { $StdinData.sessionId }
                 else { "unknown" }
    $Workspace = if ($StdinData.workspace_root) { $StdinData.workspace_root }
                 elseif ($StdinData.workspaceRoot) { $StdinData.workspaceRoot }
                 else { "unknown" }
} catch {
    $SessionId = "unknown"
    $Workspace = "unknown"
}

$LogEntry = "[$Timestamp] SESSION_START session=$SessionId workspace=$Workspace"
Add-Content -Path "$LogDir/agent-sessions.log" -Value $LogEntry

@{status = "ok"} | ConvertTo-Json -Compress
