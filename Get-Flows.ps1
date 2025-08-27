# Install modules if not already installed
# Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
# Install-Module -Name Microsoft.PowerApps.PowerShell -Scope CurrentUser


# Authenticate to Power Platform
Add-PowerAppsAccount

# List all environments you have access to
Get-AdminPowerAppEnvironment

# List all flows in the tenant
# Get-AdminFlow

# List flows that contain "Dummy" keyword
$Flows = Get-AdminFlow *Dummy*

# List flows within a specific environment
$Flows = Get-AdminFlow -EnvironmentName  # Insert EnvironmentName

# List flows created by a specific account
$Flows = Get-AdminFlow -CreatedBy  # Insert userID

$flows | Format-Table -AutoSize

