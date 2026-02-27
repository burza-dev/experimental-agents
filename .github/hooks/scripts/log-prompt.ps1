$ErrorActionPreference = "Stop"

# Log user prompts for analytics and debugging

$LogDir = if ($env:LOG_DIR) { $env:LOG_DIR } else { "./logs" }
$LogFile = Join-Path $LogDir "prompts.log"

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

try {
    $StdinData = $input | ConvertFrom-Json
    $Prompt = if ($StdinData.prompt) { 
        $StdinData.prompt.Substring(0, [Math]::Min(500, $StdinData.prompt.Length))
    } else { 
        "no-prompt" 
    }
    $SessionId = if ($StdinData.sessionId) { $StdinData.sessionId } else { "unknown" }
} catch {
    $Prompt = "parse-error"
    $SessionId = "unknown"
}

# Sanitize
$Prompt = $Prompt -replace '[\r\n]+', ' '

# Get timestamp
$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Create log entry
$LogEntry = @{
    timestamp = $Timestamp
    event = "userPrompt"
    sessionId = $SessionId
    prompt = $Prompt
}

$LogEntry | ConvertTo-Json -Compress | Out-File -FilePath $LogFile -Append -Encoding UTF8

@{status = "logged"} | ConvertTo-Json -Compress
