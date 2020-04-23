<#
    .SYNOPSIS
        Sets a folder as custom target repository

    .DESCRIPTION
        This function sets a folder as a custom target repository.
        Every *.ps1 file will be loaded as a custom target and available to be enabled for logging to.

    .PARAMETER Path
        A valid path containing *.ps1 files that defines new loggin targets

    .EXAMPLE
        PS C:\> Set-LogCustomTarget -Path C:\Logging\CustomTargets

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Set-LogCustomTarget.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/CustomTargets.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LogCustomTarget.ps1
#>
function Set-LogCustomTarget {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Set-LogCustomTarget.md')]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string] $Path
    )

    $Script:Logging.CustomTargets = $Path

    Initialize-LogTarget
}
