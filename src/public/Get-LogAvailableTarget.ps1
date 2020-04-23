<#
    .SYNOPSIS
        Returns available logging targets
    .DESCRIPTION
        This function returns available logging targtes
    .EXAMPLE
        PS C:\> Get-LogAvailableTarget
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Get-LogAvailableTarget.md
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md
    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LogAvailableTarget.ps1
#>
function Get-LogAvailableTarget {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Get-LogAvailableTarget.md')]
    param()

    return $Script:Logging.Targets
}