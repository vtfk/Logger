Import-Module "E:\scripts\Logger-TEST\src\Logger.psm1" # Add path to Logger.psm1 when testing - Remove or comment when using in production

### add Console target to make Write-Log output to Console. Default Level is INFO. No Configurations required
Add-LogTarget -Name Console -Configuration @{ Level = "DEBUG" }

### uncomment to add CMTrace target to make Write-Log output to a file in CMTrace syntax. Default Level is INFO. No Configurations required
#Add-LogTarget -Name CMTrace -Configuration @{ Level = "DEBUG" }

### uncomment to add File target to make Write-Log output to a file. Default Level is INFO. No Configurations required
#Add-LogTarget -Name File -Configuration @{ Level = "DEBUG" }

### uncomment to add Teams target to make Write-Log output to a teams channel. Default Level is INFO. Required Configurations: WebHook
#Add-LogTarget -Name Teams -Configuration @{ Level = "DEBUG"; WebHook = "https://outlook.office.com/webhook/b53e85ed-17d2-47d8-bb8d-d41ac0fbfad9@8ed93b19-ec03-482e-9854-302f1cd48360/IncomingWebhook/6e697fa62d9045d2ba853755c915450d/130ac7e2-6a62-41d5-9423-92994fdef987" }

### uncomment to add Betterstack target to make Write-Log output to a betterstack. Default Level is INFO. Required Configurations: Url and Token
#Add-LogTarget -Name Betterstack -Configuration @{ Level = "DEBUG"; Url = "https://s1183309.eu-nbg-2.betterstackdata.com"; Token = "4Hx6SW3hSaoMP2ebfGMNWLJ3" }

# Default Level is INFO
Write-Log -Message "Hei Hå!"

# set another level for this log item
Write-Log -Message "Hei Hå!" -Level WARNING

# log a body object
Write-Log -Message "ADUser" -Body (Get-ADUser -Filter "samaccountname -like 'ansattt'" | Select DistinguishedName,SamAccountName,UserPrincipalName)

# log exception
try
{
    1/0
}
catch
{
    Write-Log -Message "Å neeei" -Exception $_
}