<#
------------------------------------------------------------------------------
Capability : Azure VM Utilization Summary
Purpose   : Collect CPU, RAM, Disk IO, and Network IO utilization for all
            Virtual Machines across all subscriptions.
Output    : JSON (per-VM + subscription rollup)
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
function Get-VMUtilization {
    param([string]$SubscriptionId)

    az account set --subscription $SubscriptionId

    # List VMs
    $vms = az vm list `
        --query "[].{name:name, rg:resourceGroup, location:location}" `
        -o json | ConvertFrom-Json

    $results = @()

    foreach ($vm in $vms) {
        $vmName = $vm.name
        $rg     = $vm.rg

        # Query Azure Monitor metrics
        $metrics = az monitor metrics list `
            --resource "/subscriptions/$SubscriptionId/resourceGroups/$rg/providers/Microsoft.Compute/virtualMachines/$vmName" `
            --metric "Percentage CPU,Network In Total,Network Out Total,Disk Read Bytes,Disk Write Bytes" `
            --interval $window `
            -o json | ConvertFrom-Json

        $results += [PSCustomObject]@{
            subscription = $SubscriptionId
            vm           = $vmName
            resourceGroup = $rg
            location     = $vm.location
            metrics      = $metrics.value
        }
    }

    return $results
}

# ----------------------------- MAIN LOGIC -------------------------------------
$allResults = @()

foreach ($sub in $subscriptions) {
    $data = Get-VMUtilization -SubscriptionId $sub
    $allResults += $data
}

$allResults | ConvertTo-Json -Depth 8
