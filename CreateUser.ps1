# Install the Microsoft Entra Module ref: https://learn.microsoft.com/en-us/powershell/entra-powershell/installation
if (-not (Get-Module -Name Microsoft.Entra -ListAvailable)){
    Write-Host "Microsoft.Entra module not installed - installing it now."
    Install-Module -Name Microsoft.Entra -Repository PSGallery -Scope CurrentUser -Force -AllowClobber
}


Connect-Entra -Scopes 'User.Read.All', 'Directory.AccessAsUser.All'

# Create new user
$passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$passwordProfile.Password = ''

$params = @{
    UserPrincipalName = ''
    DisplayName = ''
    PasswordProfile = $passwordProfile
    AccountEnabled = $true
    MailNickName = ''
}

New-EntraUser @params
