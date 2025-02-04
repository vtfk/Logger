Import-Module "E:\scripts\Logger-TEST\src\Logger.psm1" # Add path to Logger.psm1 when testing - Remove or comment when using in production

### add Console target to make Write-Log output to Console. Default Level is INFO. No Configurations required
Add-LogTarget -Name Console -Configuration @{ Level = "DEBUG" }

### uncomment to add CMTrace target to make Write-Log output to a file in CMTrace syntax. Default Level is INFO. No Configurations required
#Add-LogTarget -Name CMTrace -Configuration @{ Level = "DEBUG" }

### uncomment to add File target to make Write-Log output to a file. Default Level is INFO. No Configurations required
#Add-LogTarget -Name File -Configuration @{ Level = "DEBUG" }

### uncomment to add Teams target to make Write-Log output to a teams channel. Default Level is INFO. Required Configurations: WebHook
#Add-LogTarget -Name Teams -Configuration @{ Level = "DEBUG"; WebHook = "{teams webhook}" }

### uncomment to add Betterstack target to make Write-Log output to a betterstack. Default Level is INFO. Required Configurations: Url and Token
#Add-LogTarget -Name Betterstack -Configuration @{ Level = "DEBUG"; Url = "https://{betterstackurl}.com"; Token = "{sourcetoken}" }

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