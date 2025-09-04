# Ensure Microsoft Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Installing Microsoft.Graph module..."
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

#Import-Module Microsoft.Graph

# Connect with sufficient permissions
#Connect-MgGraph -Scopes "Directory.Read.All"

# Define the target user (can be UPN or ObjectId)
$User = ""   # Or GUID like "00000000-0000-0000-0000-000000000000"

# Get all directory objects this user owns, and filter to applications
$ownedObjects = Get-MgUserOwnedObject -UserId $User -All 

# Project into a cleaner PSCustomObject
$results = $ownedObjects | ForEach-Object {
    [PSCustomObject]@{
        ODataType    = $_.AdditionalProperties.'@odata.type'
        DisplayName  = $_.AdditionalProperties.displayName
        CreatedDate  = $_.AdditionalProperties.createdDateTime
        Id           = $_.Id
    }
}

$results
