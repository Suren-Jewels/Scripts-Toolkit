# azure-api-latency.ps1
# Strict PowerShell API latency collector for Azure endpoints

Set-StrictMode -Version Latest

if (-not (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue)) {
    Write-Error "Invoke-WebRequest is required."
    exit 1
}

$EndpointsFile = $env:AZURE_API_ENDPOINTS_FILE
$OutputFile = $env:OUTPUT_FILE
if (-not $OutputFile) { $OutputFile = "azure-api-latency.json" }

if (-not $EndpointsFile) {
    Write-Error "AZURE_API_ENDPOINTS_FILE environment variable is required."
    exit 1
}

if (-not (Test-Path $EndpointsFile)) {
    Write-Error "Endpoints file not found: $EndpointsFile"
    exit 1
}

function TimestampUtc {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

$generatedAt = TimestampUtc

$results = @()

$lines = Get-Content $EndpointsFile
$lines = $lines[1..($lines.Count - 1)]

foreach ($line in $lines) {
    if (-not $line.Trim()) { continue }

    $parts = $line.Split(",")
    $service = $parts[0].Trim()
    $region = $parts[1].Trim()
    $endpoint = $parts[2].Trim()

    $start = [DateTime]::UtcNow
    try {
        $response = Invoke-WebRequest -Uri $endpoint -TimeoutSec 10 -ErrorAction Stop
        $status = $response.StatusCode
        $success = $true
    }
    catch {
        $status = 0
        $success = $false
    }
    $end = [DateTime]::UtcNow

    $latencyMs = [int]($end - $start).TotalMilliseconds

    $results += [PSCustomObject]@{
        cloud         = "azure"
        service       = $service
        region        = $region
        endpoint      = $endpoint
        status_code   = $status
        latency_ms    = $latencyMs
        success       = $success
        timestamp_utc = TimestampUtc
    }
}

$final = [PSCustomObject]@{
    meta = @{
        cloud             = "azure"
        collector         = "azure-api-latency.ps1"
        generated_at_utc  = $generatedAt
    }
    endpoints = $results
}

$final | ConvertTo-Json -Depth 6 | Out-File $OutputFile -Encoding UTF8
