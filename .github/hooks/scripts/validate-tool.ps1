$ErrorActionPreference = "Stop"

# Validate tool usage before execution (preToolUse hook)
# Reads JSON input from stdin with toolName and toolInput
#
# Blocking response format (Copilot CLI):
#   {"blocked": true, "message": "reason"}
#
# Note: VS Code equivalent uses hookSpecificOutput.permissionDecision
# with values "allow" or "deny" plus a message field.

# Dangerous command patterns to block
# NOTE: All patterns MUST be lowercase (matching is case-insensitive via .ToLower())
$DangerousPatterns = @(
    "rm -rf /",
    "rm -rf /*",
    "rm -rf ~",
    "rm -rf .",
    "rm -rf ..",
    "mkfs",
    "mkfs.",
    "format c:",
    "dd if=/dev/zero",
    "dd if=/dev/random",
    "> /dev/sda",
    "chmod -R 777 /",
    ":(){ :|:& };:",
    "--recursive --force /",
    "--force --recursive /"
)

try {
    $StdinData = $input | ConvertFrom-Json
    $ToolName = $StdinData.toolName
} catch {
    @{blocked = $false; message = "Failed to parse input"} | ConvertTo-Json -Compress
    exit 0
}

if ([string]::IsNullOrEmpty($ToolName)) {
    @{blocked = $false; message = "No tool name provided"} | ConvertTo-Json -Compress
    exit 0
}

# For execute-type tools, check the command for dangerous patterns
if ($ToolName -in @("execute", "bash", "run_in_terminal")) {
    $CommandText = ""
    try {
        if ($StdinData.toolInput.command) {
            $CommandText = $StdinData.toolInput.command
        } elseif ($StdinData.toolInput.input) {
            $CommandText = $StdinData.toolInput.input
        }
    } catch {
        $CommandText = ""
    }

    if (-not [string]::IsNullOrEmpty($CommandText)) {
        $LowerCommand = $CommandText.ToLower()
        foreach ($Pattern in $DangerousPatterns) {
            if ($LowerCommand.Contains($Pattern)) {
                @{blocked = $true; message = "Destructive command blocked by policy: matched pattern '$Pattern'"} | ConvertTo-Json -Compress
                exit 0
            }
        }
    }
}

# Allow all other operations
@{blocked = $false; tool = $ToolName} | ConvertTo-Json -Compress
