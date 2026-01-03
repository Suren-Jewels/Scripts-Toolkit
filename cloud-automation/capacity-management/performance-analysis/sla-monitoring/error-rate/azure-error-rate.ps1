# azure-error-rate.ps1

Set-StrictMode -Version Latest

if (-not (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue)) {
    Write-Error "Invoke-WebRequest is required."
    exit 1
}

$EndpointsFile = $env:AZURE_ERROR_ENDPOINTS_FILE
$OutputFile = $env:OUTPUT_FILE
if (-not $OutputFile) { $OutputFile = "azure-error-rate.json" }

if (-not $EndpointsFile) {
    Write-Error "AZURE_ERROR_ENDPOINTS_FILE environment variable is required."
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

    try {
        $response = Invoke-WebRequest -Uri $endpoint -TimeoutSec 10 -ErrorAction Stop
        $status = $response.StatusCode
        $error = $status -ge 400
    }
    catch {
        $status = 0
        $error = $true
    }

    $results += [PSCustomObject]@{
        cloud         = "azure"
        service       = $service
        region        = $region
        endpoint      = $endpoint
        status_code   = $status
        error         = $error
        timestamp_utc = TimestampUtc
    }
}

$final = [PSCustomObject]@{
    meta = @{
        cloud            = "azure"
        collector        = "azure-error-rate.ps1"
        generated_at_utc = $generatedAt
    }
    endpoints = $results
}

$final | ConvertTo-Json -Depth 6 | Out-File $OutputFile -Encoding UTF8
