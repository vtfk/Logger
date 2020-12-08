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
        # adds calling script to configuration. this allows us to have the same target name but from different calling scripts.
        $callingScript = (Get-PSCallStack)[$Script:Logging.CallerScope] | Select -ExpandProperty ScriptName
        if ($Script:Logging.EnabledTargets.ContainsKey($PSBoundParameters.Name) -and $Script:Logging.EnabledTargets[$PSBoundParameters.Name].Caller -ne $callingScript) {
            # target is already added from another calling script, add this target with different calling script
            [int]$logTargetCount = (($Script:Logging.EnabledTargets.GetEnumerator() | Where { $_.Key -like "$($PSBoundParameters.Name)*" }).Count + 1)
            $Script:Logging.EnabledTargets["$($PSBoundParameters.Name)__$logTargetCount"] = Merge-DefaultConfig -Target $PSBoundParameters.Name -Configuration $Configuration -Caller $callingScript
        }
        else {
            # target will be added
            $Script:Logging.EnabledTargets[$PSBoundParameters.Name] = Merge-DefaultConfig -Target $PSBoundParameters.Name -Configuration $Configuration -Caller $callingScript
        }

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