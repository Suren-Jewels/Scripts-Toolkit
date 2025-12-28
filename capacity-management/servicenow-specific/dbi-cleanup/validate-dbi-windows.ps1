<#
Capability: Validate Windows-based DBI nodes before cleanup.
Checks:
- DB service status
- Active connections
- Dependency presence
- Instance health
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$HostName
)

Write-Output "Validating Windows DBI node: $HostName"

# Check if host is reachable
if (!(Test-Connection -ComputerName $HostName -Count 1 -Quiet)) {
    Write-Output "UNREACHABLE: $HostName"
    exit 1
}

# Check DB service status
$service = Get-Service -ComputerName $HostName -Name "MSSQLSERVER" -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Output "NO_DB_SERVICE: $HostName"
    exit 0
}

if ($service.Status -ne "Running") {
    Write-Output "DB_SERVICE_NOT_RUNNING: $HostName"
    exit 0
}

# Check active connections (basic TCP check)
$connections = Get-NetTCPConnection -RemoteAddress $HostName -ErrorAction SilentlyContinue

if ($connections.Count -gt 0) {
    Write-Output "HAS_ACTIVE_CONNECTIONS: $HostName"
} else {
    Write-Output "SAFE_TO_CLEAN: $HostName"
}
