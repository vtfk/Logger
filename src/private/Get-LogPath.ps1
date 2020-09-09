Function Get-LogPath
{
    param(
        [Parameter(Mandatory = $True)]
        [string]$CallingScriptPath,

        [Parameter()]
        $Path = "",

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

    # fix $Path
    if ([string]::IsNullOrEmpty($Path))
    {
        # get calling script name
        $callingScriptName = [System.IO.Path]::GetFileNameWithoutExtension($callingScriptPath)

        # add Path to Config
        $Path = "$logPath\$callingScriptName$($FileExtension)"
    }
    else
    {
        # Remove FileExtension if one is in the configured path
        if([System.IO.Path]::GetExtension($Path)) 
        {
            $FileExtension = "" 
        }

        if($Path.StartsWith($logPath)) {
            $Path = "$($Path)$($FileExtension)"
        } else {
            $Path = "$logPath\$($Path)$($FileExtension)"
        }
    }

    # make sure $logPath exists
    $outFolder = [System.IO.Path]::GetDirectoryName($Path)
    if (!(Test-Path -Path $outFolder))
    {
        New-Item -Path $outFolder -ItemType Directory -Force -Confirm:$false | Out-Null
    }

    return $Path
}