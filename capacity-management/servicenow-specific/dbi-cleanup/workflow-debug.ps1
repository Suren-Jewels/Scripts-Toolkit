<#
Capability: Debug workflow issues for Windows-based DBI nodes.
Checks:
- Host reachability
- DB service state
- Event log errors
- TCP connectivity
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$HostName
)

Write-Output "Debugging workflow for DBI host: $HostName"

# Check reachability
if (!(Test-Connection -ComputerName $HostName -Count 1 -Quiet)) {
    Write-Output "UNREACHABLE: $HostName"
    exit 1
}

# Check DB service
$service = Get-Service -ComputerName $HostName -Name "MSSQLSERVER" -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Output "NO_DB_SERVICE_FOUND"
} else {
    Write-Output "DB_SERVICE_STATUS: $($service.Status)"
}

# Check event logs for DB errors
$events = Get-WinEvent -ComputerName $HostName -LogName "Application" -MaxEvents 20 |
          Where-Object { $_.Message -like "*SQL*" }

if ($events.Count -gt 0) {
    Write-Output "RECENT_SQL_ERRORS_FOUND:"
    $events | Select-Object TimeCreated, Id, LevelDisplayName, Message
} else {
    Write-Output "NO_RECENT_SQL_ERRORS"
}

# Check active TCP connections
$connections = Get-NetTCPConnection -RemoteAddress $HostName -ErrorAction SilentlyContinue

Write-Output "ACTIVE_CONNECTIONS: $($connections.Count)"
