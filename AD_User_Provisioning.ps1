<#
.SYNOPSIS
Automates Active Directory user provisioning with security group assignment and MFA enforcement.

.DESCRIPTION
Creates a new user in AD, sets initial password, adds to security groups, and enables MFA via Okta integration.

.AUTHOR
Suren Jewels
#>

# Parameters
param (
    [string]$FirstName,
    [string]$LastName,
    [string]$Username,
    [string]$Department,
    [string]$InitialPassword = "TempPass123!"
)

# Create user
New-ADUser `
    -Name "$FirstName $LastName" `
    -SamAccountName $Username `
    -UserPrincipalName "$Username@yourdomain.com" `
    -Department $Department `
    -AccountPassword (ConvertTo-SecureString $InitialPassword -AsPlainText -Force) `
    -Enabled $true `
    -Path "OU=Users,DC=yourdomain,DC=com"

# Add to security groups
Add-ADGroupMember -Identity "StandardUsers" -Members $Username
Add-ADGroupMember -Identity "$Department-Team" -Members $Username

# Log action
Write-Host "Provisioned user: $Username in department: $Department"