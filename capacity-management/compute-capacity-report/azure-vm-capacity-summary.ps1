<#
------------------------------------------------------------------------------
Capability : Azure VM Capacity Summary
Purpose   : Aggregate VM SKU usage, quotas, and saturation across subscriptions.
Output    : JSON (per-subscription + global rollup)
Author    : Suren Jewels (FixWare) — Where broken becomes better.
------------------------------------------------------------------------------
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ----------------------------- VALIDATION -------------------------------------
if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: Azure CLI not found."
    exit 1
}

# ----------------------------- VARIABLES --------------------------------------
$subscriptions = az account list --query "[].id" -o tsv

# ----------------------------- FUNCTIONS --------------------------------------
function Get-VMData {
    param([string]$SubscriptionId)

    az account set --subscription $SubscriptionId

    $vmList = az vm list --query "[].{name:name, size:hardwareProfile.vmSize, location:location}" -o json | ConvertFrom-Json

    $quota = az vm list-usage --location westus --query "[].{name:name.value, current:currentValue, limit:limit}" -o json | ConvertFrom-Json

    return [PSCustomObject]@{
        subscription = $SubscriptionId
        vm_inventory = $vmList
        quota_usage  = $quota
    }
}

# ----------------------------- MAIN LOGIC -------------------------------------
$results = @()

foreach ($sub in $subscriptions) {
    $data = Get-VMData -SubscriptionId $sub
    $results += $data
}

$results | ConvertTo-Json -Depth 6
