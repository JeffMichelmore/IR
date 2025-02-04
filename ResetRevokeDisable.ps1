# Entra Module commands ref:
# https://learn.microsoft.com/en-us/powershell/module/microsoft.entra/?view=entra-powershell
# Install the Microsoft Entra Module ref: https://learn.microsoft.com/en-us/powershell/entra-powershell/installation
if (-not (Get-Module -Name Microsoft.Entra -ListAvailable)){
    Write-Host "Microsoft.Entra module not installed - installing it now."
    Install-Module -Name Microsoft.Entra -Repository PSGallery -Scope CurrentUser -Force -AllowClobber
}

# Function to set input CSV file path
function Set-InputCsv {
    param(
        [Parameter(Mandatory=$true)]
        [String]$requiredColumn
        )
    $script:csvObjects = $null
    Write-Host "Please provide full path to CSV file containing a $requiredColumn column." -ForegroundColor Yellow
    $csvFilePath = Read-Host
    $csvFilePath = $csvFilePath -replace '"',''
    $script:csvObjects = Import-Csv $csvFilePath
    
    while ($script:csvObjects."$requiredColumn" -eq $null){
        Write-Host "`nCould not find $requiredColumn column in the provided file: $csvFilePath" -ForegroundColor Red
        Write-Host "Please provide full path to CSV file containing a $requiredColumn column." -ForegroundColor Yellow
        $csvFilePath = Read-Host
        $csvFilePath = $csvFilePath -replace '"',''
        $script:csvObjects = Import-Csv $csvFilePath
    }
    Write-Host "Input csv successfully updated:" -ForegroundColor Green -NoNewline; Write-Host " $csvFilePath`n" -ForegroundColor Yellow
}


# Connect to Entra API with necessary scopes
Write-Host "Attempting to authenticate with Entra. Complete authentication if there is a window pop-up." -ForegroundColor Yellow
Connect-Entra -Scopes 'User.Read.All', 'Directory.AccessAsUser.All', 'User.RevokeSessions.All'
if ($?) {
    Write-Host "Authentication complete." -ForegroundColor Green
}


function Show-Menu {
    Write-Host "`r`n `r`n  Please make a selection:" -ForegroundColor Yellow
    Write-Host "`r =================================" -ForegroundColor Cyan
    Write-Host "1: Press '1' Force password reset"
    Write-Host "2: Press '2' Disable accounts"
    Write-Host "3: Press '3' Revoke tokens"
    Write-Host "Q: Press 'Q' to Quit"
}


do {
    Show-Menu
    $mainMenuSelection = Read-Host

    switch ($mainMenuSelection)
    {
        '1' {
            ##################
            # Password Reset #
            ##################

            # Get user to input csv file path containing UPNs
            Set-InputCsv -requiredColumn 'userPrincipalName'

            # output each upn for confirmation before taking action
            foreach ($upn in $csvObjects.userPrincipalName){
                Write-Host $upn
            }
            Write-Host "Are you sure you wish to force a password reset for the above users? (Y/N)" -ForegroundColor Green
            $confirm = Read-Host

            # take action after confirmation, else break
            switch ($confirm) {
                'Y' {
                    foreach ($upn in $csvObjects.userPrincipalName){
                        $params = @{
                            UserID = "$upn"
                            PasswordProfile = @{
                                ForceChangePasswordNextLogIn = $true
                            }
                        }
                        Set-EntraUser @params
                        Get-EntraUser -ObjectId "$upn" | Select-Object userPrincipalName, PasswordProfile
                    }

                    if ($?) {
                        Write-Host "Successfully updated every user." -ForegroundColor Green
                    }

                }
                'N' {
                    break
                }
                default {
                    break
                }
            }
        }
        '2' {
            ####################
            # Disable Accounts #
            ####################

            # Get user to input csv file path containing UPNs
            Set-InputCsv -requiredColumn 'userPrincipalName'

            # output each upn for confirmation before taking action
            foreach ($upn in $csvObjects.userPrincipalName){
                Write-Host $upn
            }
            Write-Host "Are you sure you wish to disable the above user accounts? (Y/N)" -ForegroundColor Green
            $confirm = Read-Host

            # take action after confirmation, else break
            switch ($confirm) {
                'Y' {
                    foreach ($upn in $csvObjects.userPrincipalName){
                        $params = @{
                            UserID = "$upn"
                            AccountEnabled = $false
                        }
                        Set-EntraUser @params
                        Get-EntraUser -ObjectId "$upn" | Select-Object userPrincipalName, AccountEnabled
                    }

                    if ($?) {
                        Write-Host "Successfully updated every user." -ForegroundColor Green
                    }
                }
                'N' {
                    break
                }
                default {
                    break
                }
            }
        }
        '3' {
            #################
            # Revoke Tokens #
            #################

            # Get user to input csv file path containing UPNs
            Set-InputCsv -requiredColumn 'userPrincipalName'

            # output each upn for confirmation before taking action
            foreach ($upn in $csvObjects.userPrincipalName){
                Write-Host $upn
            }
            Write-Host "Are you sure you wish to revoke tokens for the above user? (Y/N)" -ForegroundColor Green
            $confirm = Read-Host

            # take action after confirmation, else break
            switch ($confirm) {
                'Y' {
                    foreach ($upn in $csvObjects.userPrincipalName){
                        Revoke-EntraUserAllRefreshToken -UserId $upn
                        Get-EntraUser -ObjectId "$upn" | Select-Object userPrincipalName, signInSessionsValidFromDateTime
                    }

                    if ($?) {
                        Write-Host "Successfully updated every user." -ForegroundColor Green
                    }
                }
                'N' {
                    break
                }
                default {
                    break
                }
            }
        }
    }


} until ($mainMenuSelection -eq 'Q')




