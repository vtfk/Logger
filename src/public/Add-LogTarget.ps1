<#
    .SYNOPSIS
        Enable a logging target
    .DESCRIPTION
        This function configure and enable a logging target
    .PARAMETER Name
        The name of the target to enable and configure
    .PARAMETER Configuration
        An hashtable containing the configurations for the target
    .EXAMPLE
        PS C:\> Add-LogTarget -Name Console -Configuration @{Level = 'DEBUG'}
    .EXAMPLE
        PS C:\> Add-LogTarget -Name File -Configuration @{Level = 'INFO'; Path = 'C:\Temp\script.log'}
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Add-LogTarget.md
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md
    .LINK
        https://logging.readthedocs.io/en/latest/AvailableTargets.md
    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Add-LogTarget.ps1
#>
function Add-LogTarget
{
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Add-LogTarget.md')]
    param(
        [Parameter(Position = 2)]
        [Alias("Config","Conf","Cfg","C")]
        [hashtable]$Configuration = @{}
    )

    DynamicParam {
        New-LogDynamicParam -Name 'Name' -Target
    }

    End
    {
        $Script:Logging.EnabledTargets[$PSBoundParameters.Name] = Merge-DefaultConfig -Target $PSBoundParameters.Name -Configuration $Configuration

        if ($Script:Logging.EnabledTargets.ContainsKey('CMTrace') -and $Script:Logging.EnabledTargets.ContainsKey('File') -and (($null -eq $Script:Logging.EnabledTargets['CMTrace'].Path -and $null -eq $Script:Logging.EnabledTargets['File'].Path) -or ($null -ne $Script:Logging.EnabledTargets['CMTrace'].Path -and $null -ne $Script:Logging.EnabledTargets['File'].Path -and $Script:Logging.EnabledTargets['CMTrace'].Path -eq $Script:Logging.EnabledTargets['File'].Path))) {
            # both CMTrace and File has been given
                # and Path on both of them are null 
                # or Path is given on both but they are equal...
            
            Write-Warning "'CMTrace' and 'File' logs will have the same name and will overwrite each other, unless you specify a unique Path on one of them"
        }

        if ($Script:Logging.EnabledTargets[$PSBoundParameters.Name].Init -is [scriptblock])
        {
            & $Script:Logging.EnabledTargets[$PSBoundParameters.Name].Init $Configuration
        }
    }
}