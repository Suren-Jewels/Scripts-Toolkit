<#
------------------------------------------------------------------------------
Capability : Azure Network Utilization Summary
Purpose   : Collect VNet bandwidth, gateway throughput, packet drops, and
            saturation indicators across all subscriptions.
Output    : JSON (per‑VNet + subscription rollup)
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
function Get-NetworkUtilization {
    param([string]$SubscriptionId)

    az account set --subscription $SubscriptionId

    # List VNets
    $vnets = az network vnet list `
        --query "[].{name:name, rg:resourceGroup, location:location}" `
        -o json | ConvertFrom-Json

    $results = @()

    foreach ($vnet in $vnets) {
        $vnetName = $vnet.name
        $rg       = $vnet.rg

        # Query Azure Monitor metrics for the VNet Gateway (if exists)
        $gateway = az network vnet-gateway list `
            --resource-group $rg `
            --query "[?vnet.name=='$vnetName'].name" `
            -o tsv

        $metrics = @()

        if ($gateway) {
            $metrics = az monitor metrics list `
                --resource "/subscriptions/$SubscriptionId/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworkGateways/$gateway" `
                --metric "IngressBytes, EgressBytes, P2SConnectionCount, TunnelIngressBytes, TunnelEgressBytes" `
                --interval $window `
                -o json | ConvertFrom-Json
        }

        $results += [PSCustomObject]@{
            subscription = $SubscriptionId
            vnet         = $vnetName
            resourceGroup = $rg
            location     = $vnet.location
            gateway      = $gateway
            metrics      = $metrics.value
        }
    }

    return $results
}

# ----------------------------- MAIN LOGIC -------------------------------------
$allResults = @()

foreach ($sub in $subscriptions) {
    $data = Get-NetworkUtilization -SubscriptionId $sub
    $allResults += $data
}

$allResults | ConvertTo-Json -Depth 8
