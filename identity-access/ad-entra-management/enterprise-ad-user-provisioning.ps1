<#
.SYNOPSIS
    Automated user provisioning workflow for Active Directory / Entra ID environments.

.DESCRIPTION
    Creates a new user account, assigns baseline security groups, applies conditional MFA flags,
    and logs all provisioning actions. This script is designed as a reusable identity lifecycle
    automation pattern for enterprise environments.

    NOTE:
    - All domain names, OU paths, and group names are placeholders.
    - Replace with environment-specific values before production use.

.AUTHOR
    Suren Jewels
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$FirstName,

    [Parameter(Mandatory = $true)]
    [string]$LastName,

    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$Department,

    [string]$InitialPassword = "TempPass123!",
    
    [switch]$EnableMFA
)

# -----------------------------
# Configuration (Sanitized)
# -----------------------------
$DomainName        = "example.local"
$UserPrincipalName = "$Username@$DomainName"
$OUPath            = "OU=Users,DC=example,DC=local"

$BaselineGroups = @(
    "GRP-Standard-Users",
    "GRP-Dept-$Department"
)

# -----------------------------
# Logging Function
# -----------------------------
function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "[$timestamp] $Message"
}

# -----------------------------
# Validation
# -----------------------------
Write-Log "Validating environment..."

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    throw "ActiveDirectory module not found. Install RSAT tools before running this script."
}

if (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue) {
    throw "User '$Username' already exists. Provisioning aborted."
}

Write-Log "Validation complete."

# -----------------------------
# Create User
# -----------------------------
Write-Log "Creating user account for $FirstName $LastName..."

try {
    New-ADUser `
        -Name "$FirstName $LastName" `
        -GivenName $FirstName `
        -Surname $LastName `
        -SamAccountName $Username `
        -UserPrincipalName $UserPrincipalName `
        -Department $Department `
        -AccountPassword (ConvertTo-SecureString $InitialPassword -AsPlainText -Force) `
        -Enabled $true `
        -Path $OUPath `
        -ChangePasswordAtLogon $true

    Write-Log "User account created successfully."
}
catch {
    throw "Failed to create user account: $_"
}

# -----------------------------
# Group Assignment
# -----------------------------
Write-Log "Assigning security groups..."

foreach ($group in $BaselineGroups) {
    try {
        Add-ADGroupMember -Identity $group -Members $Username -ErrorAction Stop
        Write-Log "Added user to group: $group"
    }
    catch {
        Write-Log "WARNING: Failed to add user to group '$group'. Error: $_"
    }
}

# -----------------------------
# MFA Flag (Generic Pattern)
# -----------------------------
if ($EnableMFA) {
    Write-Log "Applying MFA enrollment flag (generic pattern)..."

    # Placeholder for Okta / Entra MFA integration
    # Example: Invoke-RESTMethod -Uri $MFAEndpoint -Method POST -Body $Payload

    Write-Log "MFA flag applied (placeholder). Replace with environment-specific logic."
}

# -----------------------------
# Completion
# -----------------------------
Write-Log "Provisioning complete for user: $Username"
Write-Log "UserPrincipalName: $UserPrincipalName"
Write-Log "Department: $Department"
Write-Log "MFA Enabled: $EnableMFA"
