<#
    .SYNOPSIS
        Sets a global logging message format

    .DESCRIPTION
        This function sets a global logging message format

    .PARAMETER Format
        The string used to format the message to log

    .EXAMPLE
        PS C:\> Set-LogDefaultFormat -Format '[%{level:-7}] %{message}'

    .EXAMPLE
        PS C:\> Set-LogDefaultFormat

        It sets the default format as [%{timestamp:+%Y-%m-%d %T%Z}] [%{level:-7}] %{message}

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Set-LogDefaultFormat.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/LoggingFormat.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LogDefaultFormat.ps1
#>
function Set-LogDefaultFormat {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Set-LogDefaultFormat.md')]
    param(
        [string] $Format = $Defaults.Format
    )

    $Script:Logging.Format = $Format

    # Setting format on already configured targets
    foreach ($Target in $Script:Logging.EnabledTargets.Values) {
        if ($Target.ContainsKey('Format')) {
            $Target['Format'] = $Script:Logging.Format
        }
    }

    # Setting format on available targets
    foreach ($Target in $Script:Logging.Targets.Values) {
        if ($Target.Defaults.ContainsKey('Format')) {
            $Target.Defaults.Format.Default = $Script:Logging.Format
        }
    }
}
