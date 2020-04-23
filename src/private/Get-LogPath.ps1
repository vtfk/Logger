Function Get-LogPath
{
    param(
        [Parameter(Mandatory = $True)]
        [string]$CallingScriptPath,

        [Parameter(Mandatory = $True)]
        $Config,

        [Parameter()]
        [string]$FileExtension = ".log"
    )

    $FileExtension = ".$($FileExtension.TrimStart("."))"

    $callingScriptFolder = Split-Path -Path $callingScriptPath -Parent

    if (!$callingScriptPath -or !$callingScriptPath.StartsWith($SCRIPT_DIR))
    {
        # if script is saved somewhere it's not supposed to....
        throw "Du må lagre fila i en undermappe i '$SCRIPT_DIR' først"
    }

    # if callingScriptFolder equals $SCRIPT_DIR, throw error
    if ($callingScriptFolder -eq $SCRIPT_DIR)
    {
        throw "Running script '$callingScriptPath' must be nested in a project name (folder) under '$SCRIPT_DIR'."
    }

    # make project path from calling script
    $logPath = $callingScriptFolder.Replace($SCRIPT_DIR, $LOG_DIR)

    # fix $Config.Path
    if ([string]::IsNullOrEmpty($Config.Path))
    {
        # get calling script name
        $callingScriptName = [System.IO.Path]::GetFileNameWithoutExtension($callingScriptPath)

        # add Path to Config
        $Config.Path = "$logPath\$callingScriptName$($FileExtension)"
    }
    else
    {
        # Remove FileExtension if one is in the configured path
        if([System.IO.Path]::GetExtension($Config.Path)) 
        {
            $FileExtension = "" 
        }

        if($Config.Path.StartsWith($logPath)) {
            $Config.Path = "$($Config.Path)$($FileExtension)"
        } else {
            $Config.Path = "$logPath\$($Config.Path)$($FileExtension)"
        }
    }

    # make sure $logPath exists
    if (!(Test-Path -Path $logPath))
    {
        New-Item -Path $logPath -ItemType Directory -Force -Confirm:$false | Out-Null
    }

    return $Config.Path
}