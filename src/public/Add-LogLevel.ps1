<#
    .SYNOPSIS
        Define a new severity level

    .DESCRIPTION
        This function add a new severity level to the ones already defined

    .PARAMETER Level
        An integer that identify the severity of the level, higher the value higher the severity of the level
        By default the module defines this levels:
        NOTSET   0
        DEBUG   10
        INFO    20
        WARNING 30
        ERROR   40

    .PARAMETER LevelName
        The human redable name to assign to the level

    .EXAMPLE
        PS C:\> Add-LogLevel -Level 41 -LevelName CRITICAL

    .EXAMPLE
        PS C:\> Add-LogLevel -Level 15 -LevelName VERBOSE

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Add-LogLevel.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Add-LogLevel.ps1
#>
function Add-LogLevel
{
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Add-LogLevel.md')]
    param(
        [Parameter(Mandatory = $True)]
        [int]$Level,
        
        [Parameter(Mandatory = $True)]
        [string]$LevelName
    )

    if ($Level -notin $LevelNames.Keys -and $LevelName -notin $LevelNames.Keys)
    {
        $LevelNames[$Level] = $LevelName.ToUpper()
        $LevelNames[$LevelName] = $Level
    }
    elseif ($Level -in $LevelNames.Keys -and $LevelName -notin $LevelNames.Keys)
    {
        $LevelNames.Remove($LevelNames[$Level]) | Out-Null
        $LevelNames[$Level] = $LevelName.ToUpper()
        $LevelNames[$LevelNames[$Level]] = $Level
    }
    elseif ($Level -notin $LevelNames.Keys -and $LevelName -in $LevelNames.Keys)
    {
        $LevelNames.Remove($LevelNames[$LevelName]) | Out-Null
        $LevelNames[$LevelName] = $Level
    }
}
