<#
    .SYNOPSIS
        Returns the default message level

    .DESCRIPTION
        This function returns a string representing the default message level used by enabled targets that don't override it

    .EXAMPLE
        PS C:\> Get-LogDefaultLevel

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Get-LogDefaultLevel.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LogDefaultLevel.ps1
#>
function Get-LogDefaultLevel
{
    [CmdletBinding(HelpUri = 'https://logging.readthedocs.io/en/latest/functions/Get-LogDefaultLevel.md')]
    param()

    return Get-LevelName -Level $Script:Logging.LevelNo
}
