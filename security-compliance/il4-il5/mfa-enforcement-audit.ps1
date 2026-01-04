#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Audits MFA enforcement compliance for IL4/IL5 users.

.DESCRIPTION
    Reads a user list from CSV and reports whether MFA is enabled/enforced.
    Expected CSV columns: UserPrincipalName, MFAEnabled, MFAEnforced
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserCsvPath
)

if (-not (Test-Path -Path $UserCsvPath)) {
    Write-Error "[ERROR] CSV file not found: $UserCsvPath"
    exit 1
}

$users = Import-Csv -Path $UserCsvPath

$nonCompliant = @()

Write-Output "[RESULT] MFA Enforcement Audit"

foreach ($user in $users) {
    $upn = $user.UserPrincipalName
    $enabled = [string]$user.MFAEnabled
    $enforced = [string]$user.MFAEnforced

    $isCompliant = ($enabled -eq "True" -and $enforced -eq "True")

    if ($isCompliant) {
        Write-Output " - $upn : COMPLIANT"
    } else {
        Write-Output " - $upn : NON-COMPLIANT"
        $nonCompliant += $upn
    }
}

if ($nonCompliant.Count -eq 0) {
    Write-Output "All users meet MFA enforcement requirements."
    exit 0
} else {
    Write-Output "$($nonCompliant.Count) user(s) failed MFA requirements."
    exit 2
}
