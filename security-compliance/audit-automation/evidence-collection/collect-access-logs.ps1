<# 
.SYNOPSIS
    Collects access logs from Windows/Linux (PowerShell Core) environments.

.DESCRIPTION
    - Reads paths from a config file or parameters
    - Filters by time window
    - Produces a timestamped evidence directory and compressed archive
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string] $ConfigPath = "./collect-access-logs.json",

    [Parameter(Mandatory = $false)]
    [string] $OutputDirectory = "/var/tmp/evidence-access-logs",

    [Parameter(Mandatory = $false)]
    [int] $Days = 7,

    [Parameter(Mandatory = $false)]
    [switch] $VerboseLogging
)

# Enable verbose preference if requested
if ($VerboseLogging) {
    $VerbosePreference = "Continue"
}

function Write-Info {
    param([string] $Message)
    Write-Host "[INFO]  $Message"
}

function Write-Warn {
    param([string] $Message)
    Write-Warning $Message
}

function Write-Err {
    param([string] $Message)
    Write-Error $Message
}

function Load-Config {
    param([string] $Path)

    if (Test-Path -LiteralPath $Path) {
        Write-Info "Loading configuration from $Path"
        try {
            $json = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
            return $json
        }
        catch {
            Write-Err "Failed to parse config file '$Path': $_"
            return $null
        }
    }
    else {
        Write-Verbose "Config file '$Path' not found; using default/parameter values."
        return $null
    }
}

function Get-EffectiveSettings {
    param(
        [object] $Config,
        [string] $OutputDirectory,
        [int] $Days
    )

    # Config file can override parameters if provided
    $settings = [ordered]@{}
    $settings.OutputDirectory = if ($Config -and $Config.OutputDirectory) {
        $Config.OutputDirectory
    } else {
        $OutputDirectory
    }

    $settings.Days = if ($Config -and $Config.Days) {
        [int]$Config.Days
    } else {
        $Days
    }

    # CollectionPaths is a list of folders/files (e.g. IIS logs, app logs)
    $settings.CollectionPaths = if ($Config -and $Config.CollectionPaths) {
        @($Config.CollectionPaths)
    } else {
        @("/var/log", "/var/log/nginx", "/var/log/httpd", "C:\inetpub\logs\LogFiles")
    }

    return $settings
}

function New-SafeDirectory {
    param([string] $Path)

    try {
        if (-not (Test-Path -LiteralPath $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-Info "Created directory: $Path"
        }
    }
    catch {
        Write-Err "Failed to create directory '$Path': $_"
        throw
    }
}

function Collect-AccessLogs {
    param(
        [string[]] $Paths,
        [string] $TargetDirectory,
        [int] $Days
    )

    $cutoff = (Get-Date).AddDays(-1 * $Days)
    Write-Info "Collecting logs modified since $cutoff"

    foreach ($p in $Paths) {
        $trimmed = $p.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }

        if (-not (Test-Path -LiteralPath $trimmed)) {
            Write-Warn "Path does not exist, skipping: $trimmed"
            continue
        }

        Write-Info "Processing path: $trimmed"

        try {
            # Use Get-ChildItem recursively for files; filter by LastWriteTime
            $items = Get-ChildItem -LiteralPath $trimmed -Recurse -ErrorAction SilentlyContinue |
                Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -ge $cutoff }

            foreach ($item in $items) {
                $relative = $item.FullName
                # Normalize path for target (remove drive colon for Windows)
                if ($relative.Length -gt 1 -and $relative[1] -eq ":") {
                    $relative = $relative.Substring(2)  # remove "C:"
                }

                $destPath = Join-Path -Path $TargetDirectory -ChildPath $relative.TrimStart("\", "/")
                $destDir = Split-Path -Path $destPath -Parent

                if (-not (Test-Path -LiteralPath $destDir)) {
                    New-SafeDirectory -Path $destDir
                }

                Copy-Item -LiteralPath $item.FullName -Destination $destPath -Force -ErrorAction Stop
                Write-Verbose "Copied: $($item.FullName) -> $destPath"
            }
        }
        catch {
            Write-Warn "Error while processing '$trimmed': $_"
        }
    }
}

function Compress-Directory {
    param(
        [string] $SourceDirectory,
        [string] $OutputDirectory
    )

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $archiveName = "access-logs-evidence-$timestamp.zip"
    $archivePath = Join-Path -Path $OutputDirectory -ChildPath $archiveName

    try {
        Write-Info "Creating archive: $archivePath"
        if (Test-Path -LiteralPath $archivePath) {
            Remove-Item -LiteralPath $archivePath -Force
        }
        Compress-Archive -Path (Join-Path $SourceDirectory "*") -DestinationPath $archivePath -Force
        Write-Info "Access log evidence archived at: $archivePath"
    }
    catch {
        Write-Err "Failed to create archive '$archivePath': $_"
        throw
    }
}

# -----------------------------
# Main execution
# -----------------------------

try {
    $config = Load-Config -Path $ConfigPath
    $settings = Get-EffectiveSettings -Config $config -OutputDirectory $OutputDirectory -Days $Days

    Write-Verbose ("Effective settings: " + ($settings | ConvertTo-Json -Depth 4))

    $rootOutput = $settings.OutputDirectory
    New-SafeDirectory -Path $rootOutput

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $evidenceDir = Join-Path -Path $rootOutput -ChildPath ("access-logs-" + $timestamp)
    New-SafeDirectory -Path $evidenceDir

    Collect-AccessLogs -Paths $settings.CollectionPaths -TargetDirectory $evidenceDir -Days $settings.Days
    Compress-Directory -SourceDirectory $evidenceDir -OutputDirectory $rootOutput

    Write-Info "Access log evidence collection completed successfully."
}
catch {
    Write-Err "Unexpected error during access log collection: $_"
    exit 1
}
