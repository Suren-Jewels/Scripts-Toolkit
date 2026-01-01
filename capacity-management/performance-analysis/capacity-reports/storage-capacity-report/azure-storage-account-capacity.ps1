<#
------------------------------------------------------------------------------
Capability : Azure Storage Account Capacity Summary
Purpose   : Provide per-container and per-file-share capacity, usage, and growth
            metrics across all subscriptions.
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

# ----------------------------- FUNCTIONS --------------------------------------
function Get-StorageData {
    param([string]$SubscriptionId)

    az account set --subscription $SubscriptionId

    $accounts = az storage account list --query "[].{name:name, resourceGroup:resourceGroup, location:primaryLocation}" -o json | ConvertFrom-Json

    $result = @()

    foreach ($acct in $accounts) {
        $acctName = $acct.name
        $rg       = $acct.resourceGroup

        # Containers
        $containers = az storage container list `
            --account-name $acctName `
            --query "[].name" -o tsv 2>$null

        $containerData = foreach ($c in $containers) {
            $size = az storage blob list `
                --account-name $acctName `
                --container-name $c `
                --query "sum([].properties.contentLength)" -o tsv 2>$null

            [PSCustomObject]@{
                container = $c
                sizeBytes = ($size | ForEach-Object { if ($_ -eq "") { 0 } else { $_ } })
            }
        }

        # File Shares
        $shares = az storage share list `
            --account-name $acctName `
            --query "[].name" -o tsv 2>$null

        $shareData = foreach ($s in $shares) {
            $quota = az storage share show `
                --account-name $acctName `
                --name $s `
                --query "{quota:quota, usage:properties.shareUsageBytes}" -o json 2>$null | ConvertFrom-Json

            [PSCustomObject]@{
                share = $s
                quotaGB = $quota.quota
                usageBytes = $quota.usage
            }
        }

        $result += [PSCustomObject]@{
            subscription = $SubscriptionId
            storageAccount = $acctName
            location = $acct.location
            containers = $containerData
            fileShares = $shareData
        }
    }

    return $result
}

# ----------------------------- MAIN LOGIC -------------------------------------
$allResults = @()

foreach ($sub in $subscriptions) {
    $data = Get-StorageData -SubscriptionId $sub
    $allResults += $data
}

$allResults | ConvertTo-Json -Depth 8
