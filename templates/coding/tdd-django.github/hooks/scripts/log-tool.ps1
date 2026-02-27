$ErrorActionPreference = "Stop"

# PostToolUse hook — logs tool usage for audit trail.
# Records tool name, timestamp, and result status.
# VS Code canonical format (snake_case input fields).

$LogDir = if ($env:AGENT_LOG_DIR) { $env:AGENT_LOG_DIR } else { "./logs" }
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

try {
    $StdinData = $input | ConvertFrom-Json
    $ToolName = if ($StdinData.tool_name) { $StdinData.tool_name }
                elseif ($StdinData.toolName) { $StdinData.toolName }
                else { "unknown" }
    $Success = if ($null -ne $StdinData.success) { $StdinData.success } else { "unknown" }
} catch {
    $ToolName = "unknown"
    $Success = "unknown"
}

$LogEntry = "[$Timestamp] TOOL_USE tool=$ToolName success=$Success"
Add-Content -Path "$LogDir/tool-usage.log" -Value $LogEntry

@{status = "ok"} | ConvertTo-Json -Compress
