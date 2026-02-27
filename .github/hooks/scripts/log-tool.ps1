$ErrorActionPreference = "Stop"

# Log tool execution results for auditing
# Reads JSON input from stdin with toolName, toolArgs, and result

$LogDir = if ($env:LOG_DIR) { $env:LOG_DIR } else { "./logs" }
$LogFile = Join-Path $LogDir "tool-usage.log"

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

try {
    $StdinData = $input | ConvertFrom-Json
    $ToolName = if ($StdinData.toolName) { $StdinData.toolName } else { "unknown" }
    $ToolArgs = if ($StdinData.toolInput) { $StdinData.toolInput } elseif ($StdinData.toolArgs) { $StdinData.toolArgs } else { @{} }
    
    # Get result and truncate to avoid huge log entries
    $Result = if ($StdinData.toolOutput) { 
        $StdinData.toolOutput
    } elseif ($StdinData.result) { 
        $StdinData.result 
    } elseif ($StdinData.toolResult) { 
        $StdinData.toolResult 
    } else { 
        "no-result" 
    }
    
    # Truncate result summary
    $ResultSummary = if ($Result -is [string]) {
        if ($Result.Length -gt 200) { $Result.Substring(0, 200) } else { $Result }
    } else {
        $ResultJson = $Result | ConvertTo-Json -Compress
        if ($ResultJson.Length -gt 200) { $ResultJson.Substring(0, 200) } else { $ResultJson }
    }
    
    # Sanitize newlines
    $ResultSummary = $ResultSummary -replace '[\r\n]+', ' '
    
} catch {
    # If parsing fails, log the error but continue
    $ToolName = "parse-error"
    $ToolArgs = @{}
    $ResultSummary = $_.Exception.Message
}

# Get timestamp in ISO 8601 format
$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Create log entry
$LogEntry = @{
    timestamp = $Timestamp
    event = "postToolUse"
    tool = $ToolName
    args = $ToolArgs
    result = $ResultSummary
}

# Append to log file
$LogEntry | ConvertTo-Json -Compress | Out-File -FilePath $LogFile -Append -Encoding UTF8

# Output success response
@{status = "continue"} | ConvertTo-Json -Compress
