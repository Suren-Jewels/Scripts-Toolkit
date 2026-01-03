<#
------------------------------------------------------------------------------
Capability : Azure Network Capacity Summary
Purpose   : Summarize bandwidth consumption, gateway throughput, endpoint usage,
            and saturation indicators across all VNets in all subscriptions.
Output    : JSON (per-VNet + subscription rollup)
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
$window = "PT1H"   # 1 hour lookback

# ----------------------------- FUNCTIONS --------------------------------------
function Get-VNetCapacity {
    param([string]$SubscriptionId)

    az account set --subscription $SubscriptionId

    # List VNets
    $vnets = az network vnet list `
        --query "[].{name:name, rg:resourceGroup, location:location}" `
        -o json | ConvertFrom-Json

    $results = @()

    foreach ($v in $vnets) {
        $vnetName = $v.name
        $rg       = $v.rg

        # Query Network Insights metrics
        $metrics = az monitor metrics list `
            --resource "/subscriptions/$SubscriptionId/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnetName" `
            --metric "BytesIn,BytesOut,PacketsDropped" `
            --interval $window `
            -o json | ConvertFrom-Json

        $results += [PSCustomObject]@{
            subscription = $SubscriptionId
            vnet         = $vnetName
            resourceGroup = $rg
            location     = $v.location
            metrics      = $metrics.value
        }
    }

    return $results
}

# ----------------------------- MAIN LOGIC -------------------------------------
$allResults = @()

foreach ($sub in $subscriptions) {
    $data = Get-VNetCapacity -SubscriptionId $sub
    $allResults += $data
}

$allResults | ConvertTo-Json -Depth 8
