$ErrorActionPreference = "Stop"

# Handle errors during agent execution

$LogDir = if ($env:LOG_DIR) { $env:LOG_DIR } else { "./logs" }
$LogFile = Join-Path $LogDir "errors.log"

if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

try {
    $StdinData = $input | ConvertFrom-Json
    $ErrorMsg = if ($StdinData.error) { 
        $StdinData.error.Substring(0, [Math]::Min(1000, $StdinData.error.Length))
    } else { 
        "unknown-error" 
    }
    $Context = if ($StdinData.context) { 
        $val = $StdinData.context
        if ($val -is [string]) {
            $val.Substring(0, [Math]::Min(500, $val.Length))
        } else {
            $json = $val | ConvertTo-Json -Compress
            $json.Substring(0, [Math]::Min(500, $json.Length))
        }
    } else { 
        "no-context" 
    }
    $SessionId = if ($StdinData.sessionId) { $StdinData.sessionId } else { "unknown" }
} catch {
    $ErrorMsg = "parse-error: " + $_.Exception.Message
    $Context = "no-context"
    $SessionId = "unknown"
}

# Sanitize
$ErrorMsg = $ErrorMsg -replace '[\r\n]+', ' '
$Context = $Context -replace '[\r\n]+', ' '

$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$LogEntry = @{
    timestamp = $Timestamp
    event = "error"
    sessionId = $SessionId
    error = $ErrorMsg
    context = $Context
}

$LogEntry | ConvertTo-Json -Compress | Out-File -FilePath $LogFile -Append -Encoding UTF8

@{status = "logged"; continue = $true} | ConvertTo-Json -Compress
