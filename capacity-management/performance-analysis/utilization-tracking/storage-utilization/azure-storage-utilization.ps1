<#
------------------------------------------------------------------------------
Capability : Azure Storage Utilization Summary
Purpose   : Collect IOPS, throughput, latency, and capacity utilization for all
            Azure Storage Accounts across all subscriptions.
Output    : JSON (per-storage-account + subscription rollup)
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
function Get-StorageUtilization {
    param([string]$SubscriptionId)

    az account set --subscription $SubscriptionId

    # List storage accounts
    $accounts = az storage account list `
        --query "[].{name:name, rg:resourceGroup, location:primaryLocation}" `
        -o json | ConvertFrom-Json

    $results = @()

    foreach ($acct in $accounts) {
        $acctName = $acct.name
        $rg       = $acct.rg

        # Query Azure Monitor metrics
        $metrics = az monitor metrics list `
            --resource "/subscriptions/$SubscriptionId/resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/$acctName" `
            --metric "UsedCapacity,Transactions,Ingress,Egress,SuccessE2ELatency,SuccessServerLatency" `
            --interval $window `
            -o json | ConvertFrom-Json

        $results += [PSCustomObject]@{
            subscription = $SubscriptionId
            storageAccount = $acctName
            resourceGroup = $rg
            location = $acct.location
            metrics = $metrics.value
        }
    }

    return $results
}

# ----------------------------- MAIN LOGIC -------------------------------------
$allResults = @()

foreach ($sub in $subscriptions) {
    $data = Get-StorageUtilization -SubscriptionId $sub
    $allResults += $data
}

$allResults | ConvertTo-Json -Depth 8
