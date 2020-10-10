Function Get-LogPath
{
    param(
        [Parameter(Mandatory = $True)]
        [string]$CallingScriptPath,

        [Parameter()]
        $Path = "",

        [Parameter()]
        [string]$FileExtension = ".log",

        [Parameter()]
        $CallerShortcut
    )

    $FileExtension = ".$($FileExtension.TrimStart("."))"

    # get calling script folder path
    $callingScriptFolder = Split-Path -Path $callingScriptPath -Parent

    if (!$callingScriptPath -or !$callingScriptPath.StartsWith($env:SCRIPT_DIR))
    {
        # if script is saved somewhere it's not supposed to....
        throw "Script must be saved in a subfolder in '$env:SCRIPT_DIR' first"
    }

    # if callingScriptFolder equals $env:SCRIPT_DIR, throw error
    if ($callingScriptFolder -eq $env:SCRIPT_DIR)
    {
        throw "Running script '$callingScriptPath' must be nested in a project name (folder) under '$env:SCRIPT_DIR'."
    }

    # get calling script name
    $callingScriptName = [System.IO.Path]::GetFileNameWithoutExtension($callingScriptPath)

    # make project path from calling script
    $logPath = $callingScriptFolder.Replace($env:SCRIPT_DIR, $env:LOG_DIR)

    # fix $Path
    if ([string]::IsNullOrEmpty($Path))
    {
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

        # replace $CallerShortcut with $callingScriptName
        $Path = $Path.Replace($CallerShortcut, $callingScriptName)
    }

    # make sure $logPath exists
    $outFolder = [System.IO.Path]::GetDirectoryName($Path)
    if (!(Test-Path -Path $outFolder))
    {
        New-Item -Path $outFolder -ItemType Directory -Force -Confirm:$false | Out-Null
    }

    return $Path
}