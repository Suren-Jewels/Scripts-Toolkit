<#
.SYNOPSIS
    Runs a monthly user access review based on a configuration file.

.DESCRIPTION
    This script performs a monthly access review by:
      - Loading a configuration (JSON or YAML if supported)
      - Querying user/system data (placeholder for directory/IdP/HR systems)
      - Generating a simple review report
      - Logging details for audit trails

    It is intended to be triggered by a scheduler (Task Scheduler, Azure Automation, etc.).

.PARAMETER ConfigPath
    Path to the configuration file (JSON or YAML).

.PARAMETER LogPath
    Path to the log file. Default: C:\Logs\audit-automation\monthly-access-review.log

.PARAMETER DryRun
    If specified, the script will only log intended actions without performing changes.

.EXAMPLE
    .\monthly-access-review.ps1 -ConfigPath "C:\config\monthly-access.json"

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ConfigPath,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$LogPath = "C:\Logs\audit-automation\monthly-access-review.log",

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

# Ensure script stops on non-terminating errors in critical sections
$ErrorActionPreference = "Stop"

# --- Logging helper ---
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    $entry = "$timestamp [monthly-access-review] [$Level] $Message"

    # Write to console
    Write-Host $entry

    # Write to file (best-effort)
    if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
        try {
            $logDir = Split-Path -Path $LogPath -Parent
            if (-not (Test-Path -Path $logDir)) {
                New-Item -ItemType Directory -Path $logDir -Force | Out-Null
            }
            Add-Content -Path $LogPath -Value $entry
        }
        catch {
            # Logging must not interrupt execution
            Write-Host "$timestamp [monthly-access-review] [WARN] Failed to write to log file: $($_.Exception.Message)"
        }
    }
}

# --- Configuration loader ---
function Get-Config {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        throw "Config file does not exist: $Path"
    }

    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()

    try {
        $raw = Get-Content -Path $Path -Raw -ErrorAction Stop
    }
    catch {
        throw "Failed to read config file: $($_.Exception.Message)"
    }

    switch ($extension) {
        ".json" {
            try {
                return $raw | ConvertFrom-Json -ErrorAction Stop
            }
            catch {
                throw "Failed to parse JSON config: $($_.Exception.Message)"
            }
        }
        ".yaml" { }
        ".yml"  { }
        default {
            throw "Unsupported config format '$extension'. Use .json, .yaml, or .yml."
        }
    }

    # YAML parsing is intentionally left as a stub to avoid dependency assumptions.
    # You may integrate a YAML parser module and handle it here.
    throw "YAML config is not supported by default in this script. Implement a YAML parser if needed."
}

# --- Example: fetch users from an external system (stub) ---
function Get-UsersForReview {
    param(
        [Parameter(Mandatory = $true)]
        $Config
    )

    # In a real implementation, this might query:
    #   - Active Directory / Entra ID
    #   - HR systems
    #   - Identity providers
    #
    # This stub returns a fixed set of example users.

    $source = $Config.userSource
    Write-Log -Level "INFO" -Message "Fetching users from source: $source"

    $users = @(
        [PSCustomObject]@{
            UserId       = "alice"
            DisplayName  = "Alice Example"
            Department   = "Engineering"
            Role         = "Admin"
            LastLoginUtc = (Get-Date).AddDays(-3).ToString("u")
        },
        [PSCustomObject]@{
            UserId       = "bob"
            DisplayName  = "Bob Example"
            Department   = "Finance"
            Role         = "ReadOnly"
            LastLoginUtc = (Get-Date).AddDays(-90).ToString("u")
        }
    )

    return $users
}

# --- Example: apply access review rules ---
function Invoke-AccessReview {
    param(
        [Parameter(Mandatory = $true)]
        $Config,

        [Parameter(Mandatory = $true)]
        [System.Collections.IEnumerable]$Users
    )

    $maxInactivityDays = $Config.maxInactivityDays
    if (-not $maxInactivityDays) {
        $maxInactivityDays = 60
    }

    $now = Get-Date
    $reviewItems = @()

    foreach ($user in $Users) {
        $userId = $user.UserId
        $displayName = $user.DisplayName
        $role = $user.Role

        # Parse last login; if invalid, flag for review
        $lastLogin = $null
        try {
            $lastLogin = [DateTime]::Parse($user.LastLoginUtc)
        }
        catch {
            Write-Log -Level "WARN" -Message "User '$userId' has invalid LastLoginUtc; flagging for review."
            $reviewItems += [PSCustomObject]@{
                UserId       = $userId
                DisplayName  = $displayName
                Role         = $role
                Reason       = "InvalidLastLogin"
                LastLoginUtc = $user.LastLoginUtc
            }
            continue
        }

        $inactivity = ($now - $lastLogin).TotalDays

        if ($inactivity -ge $maxInactivityDays) {
            Write-Log -Level "INFO" -Message "User '$userId' inactive for $([math]::Round($inactivity, 1)) days; flagging for review."
            $reviewItems += [PSCustomObject]@{
                UserId       = $userId
                DisplayName  = $displayName
                Role         = $role
                Reason       = "Inactivity"
                LastLoginUtc = $user.LastLoginUtc
            }
        }
    }

    return $reviewItems
}

# --- Example: export review report ---
function Export-AccessReviewReport {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IEnumerable]$Items,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    $outputDir = Split-Path -Path $OutputPath -Parent
    if (-not (Test-Path -Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    try {
        $Items | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding UTF8 -Force
        Write-Log -Level "INFO" -Message "Access review report written to: $OutputPath"
    }
    catch {
        throw "Failed to write access review report: $($_.Exception.Message)"
    }
}

# --- Main script logic ---
try {
    Write-Log -Level "INFO" -Message "monthly-access-review started. DryRun=$($DryRun.IsPresent)"

    $config = Get-Config -Path $ConfigPath

    if (-not $config.reviewOutputPath) {
        $dateStamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $defaultOutput = "C:\Logs\audit-automation\reports\access-review_$dateStamp.json"
        Write-Log -Level "WARN" -Message "reviewOutputPath not set in config; defaulting to $defaultOutput"
        $config | Add-Member -NotePropertyName "reviewOutputPath" -NotePropertyValue $defaultOutput -Force
    }

    $users = Get-UsersForReview -Config $config
    Write-Log -Level "INFO" -Message ("Fetched {0} user(s) for review." -f ($users | Measure-Object).Count)

    $reviewItems = Invoke-AccessReview -Config $config -Users $users
    Write-Log -Level "INFO" -Message ("Identified {0} user(s) requiring review." -f ($reviewItems | Measure-Object).Count)

    if ($DryRun.IsPresent) {
        Write-Log -Level "INFO" -Message "[DRY-RUN] Skipping report export."
    }
    else {
        Export-AccessReviewReport -Items $reviewItems -OutputPath $config.reviewOutputPath
    }

    Write-Log -Level "INFO" -Message "monthly-access-review completed successfully."
    exit 0
}
catch {
    Write-Log -Level "ERROR" -Message "monthly-access-review failed: $($_.Exception.Message)"
    exit 1
}
finally {
    # Optionally add cleanup actions here
}
