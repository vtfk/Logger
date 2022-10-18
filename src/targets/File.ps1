@{
    Name = 'File'
    Configuration = @{
        Path         = @{Required = $false;  Type = [string];    Default = $null}
        Append       = @{Required = $false;  Type = [bool];      Default = $true}
        Encoding     = @{Required = $false;  Type = [string];    Default = 'utf8'}
        Level        = @{Required = $false;  Type = [string];    Default = $Logging.Level}
        Format       = @{Required = $false;  Type = [string];    Default = $Logging.Format}
        Sanitize     = @{Required = $false;  Type = [bool];      Default = $false}
        SanitizeMask = @{Required = $false;  Type = [char];      Default = '*'}
        RolloverType = @{Required = $false;  Type = [string];    Default = $Logging.RolloverType}
    }

    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        if ($Log.Verbose)
        {
            $VerbosePreference = "Continue"
        }

        [string]$Text = ""

        if ($Log.Body)
        {
            $Body = $Log.Body | ConvertTo-Json -Compress

            if(!$Configuration.Format.Contains("%body%"))
            {
                $Text += "`n`t$Body"
            }
        }

        if ($Log.Exception)
        {
            if ($Log.Exception.PSobject.Properties.name -match "InvocationInfo")
            {
                $Text += "`n$($Log.Exception.InvocationInfo.PositionMessage)"
            }

            if ($Log.Exception.PSobject.Properties.name -match "Exception")
            {
                $Text += "`n`n$($Log.Exception.Exception)"
            }
        }

        # construct log text
        $Text = "$(Replace-Token -String $Configuration.Format -Source $Log) $Text"
        $Text = if ($Configuration.Sanitize) { Get-SanitizedMessage -Message $Text -Mask $Configuration.SanitizeMask } else { $Text }

        # are we using Rollover? If we get back an integer and its higher than 0, we are using Rollover
        [int]$rolloverType = Get-RolloverType -Type $Configuration.RolloverType

        # pathname (ScriptName) must exist for logging to work
        if ($Log.pathname) {
            # get log path (and create it if blabla.....)
            $Configuration.Path = Get-LogPath -CallingScriptPath $Log.pathname -Path $Configuration.Path -CallerShortcut $Script:Logging.CallerShortcut

            if ($rolloverType) {
                $Configuration.Path = Get-RolloverPath -Path $Configuration.Path -Type $Configuration.RolloverType

                ## remove rollover file, if present and file is older than today
                if ((Test-Path -Path $Configuration.Path) -and ((Get-Date)-(Get-ChildItem -Path $Configuration.Path | Select -ExpandProperty LastWriteTime)).Days -gt 0)
                {
                    try {
                        Remove-Item -Path $Configuration.Path -Force -Confirm:$False -ErrorAction Stop
                        Write-Verbose "[Logger/File] Rollover file ($($Configuration.Path)) removed"
                    } catch {
                        Write-Verbose "[Logger/File] Rollover file ($($Configuration.Path)) failed to be removed : $_"
                    }
                }
            }

            $Params = @{
                Append      = $Configuration.Append
                FilePath    = Replace-Token -String $Configuration.Path -Source $Log
                Encoding    = $Configuration.Encoding
            }

            Write-Verbose "[Logger/File] Logging to: $($Params.FilePath)"
            $Text | Out-File @Params
        }
        else {
            Write-Warning "$Text :: Filepath not found (CallStack lacks necessary info)"
        }
    }
}
