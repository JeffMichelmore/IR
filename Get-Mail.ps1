# Install Microsoft Graph PowerShell module if needed
# Install-Module Microsoft.Graph -Scope CurrentUser -Force -AllowClobber
# Install-Module Microsoft.Graph.Mail -Scope CurrentUser -Force -AllowClobber
# Import-Module Microsoft.Graph.Mail


# Connect to Graph with Mail permissions
Connect-MgGraph -Scopes "Mail.ReadBasic","Mail.Read"

# Insert InternetMessageIds in below array within quotes and separated by commas.
$internetMessageIds = @()

$upn = Get-MgUser -Filter "userPrincipalName eq 'INSERT UPN'" | Select-Object -ExpandProperty UserPrincipalName

$results = @()

foreach ($internetMessageId in $internetMessageIds){
    $messages = Get-MgUserMessage -UserId $upn -Filter "internetMessageId eq '$internetMessageId'"
    foreach ($msg in $messages) {
        $results += [pscustomobject]@{
            Subject   = $msg.Subject
            To        = ($msg.ToRecipients | ForEach-Object { $_.EmailAddress.Address }) -join "; "
            Cc        = ($msg.CcRecipients | ForEach-Object { $_.EmailAddress.Address }) -join "; "
            From      = $msg.From.EmailAddress.Address
            Received  = $msg.ReceivedDateTime
        }
    }
}

# Output to console
$results | Format-Table -AutoSize


$resultOutputFile = Join-Path $PSScriptRoot "EmailItemsResults.csv"
Write-Host "Writing results to $resultOutputFile" -ForegroundColor Yellow

$results | ConvertTo-Csv -NoTypeInformation | Set-Content $resultOutputFile -Force 

Write-Host "Successfully created $resultOutputFile" -ForegroundColor Yellow
Invoke-Item -Path $resultOutputFile
