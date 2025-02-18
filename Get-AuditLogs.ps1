# Entra Module commands ref:
# https://learn.microsoft.com/en-us/powershell/module/microsoft.entra/?view=entra-powershell
# Install the Microsoft Entra Module ref: https://learn.microsoft.com/en-us/powershell/entra-powershell/installation
if (-not (Get-Module -Name Microsoft.Entra -ListAvailable)){
    Write-Host "Microsoft.Entra module not installed - installing it now."
    Install-Module -Name Microsoft.Entra -Repository PSGallery -Scope CurrentUser -Force -AllowClobber
}

# Connect to Entra API with necessary scopes
Write-Host "Attempting to authenticate with Entra. Complete authentication if there is a window pop-up." -ForegroundColor Yellow
Connect-Entra -Scopes 'User.Read.All', 'Directory.Read.All', 'AuditLog.Read.All'
if ($?) {
    Write-Host "Authentication complete." -ForegroundColor Green
}

# Get all possible properties of entra audit log

# Get-EntraAuditDirectoryLog -top 1 | Select-Object -Property * | Format-List

Get-EntraAuditSignInLog -top 1 | Select-Object -Property * | Format-List