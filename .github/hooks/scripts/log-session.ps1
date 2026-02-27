param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "end")]
    [string]$Action
)

$ErrorActionPreference = "Stop"

# Log session start/end events

# Read JSON context from stdin and parse sessionId for log correlation
$SessionId = "unknown"
try {
    $StdinData = $input | ConvertFrom-Json
    if ($StdinData.sessionId) {
        $SessionId = $StdinData.sessionId
    }
} catch {
    # Parsing failed — continue with unknown sessionId
}

$Timestamp = Get-Date -Format "o"
$LogDir = if ($env:LOG_DIR) { $env:LOG_DIR } else { "./logs" }
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}
$LogFile = Join-Path $LogDir "session.log"

function Write-Log {
    param([string]$Message)
    try {
        Add-Content -Path $LogFile -Value "[$Timestamp] [session:$SessionId] $Message" -Encoding UTF8 -ErrorAction Stop
    } catch {
        # Log failure is non-fatal, continue
        Write-Warning "Failed to write log: $_"
    }
}

try {
    switch ($Action) {
        "start" {
            Write-Log "Session started"
            @{status = "logged"; action = "start"} | ConvertTo-Json -Compress
        }
        "end" {
            Write-Log "Session ended"
            @{status = "logged"; action = "end"} | ConvertTo-Json -Compress
        }
    }
} catch {
    @{status = "error"; message = $_.Exception.Message} | ConvertTo-Json -Compress
    exit 1
}
