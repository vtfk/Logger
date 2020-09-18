@{
    Name = 'File'
    Configuration = @{
        Path        = @{Required = $false;  Type = [string];    Default = $null}
        Append      = @{Required = $false;  Type = [bool];      Default = $true}
        Encoding    = @{Required = $false;  Type = [string];    Default = 'utf8'}
        Level       = @{Required = $false;  Type = [string];    Default = $Logging.Level}
        Format      = @{Required = $false;  Type = [string];    Default = $Logging.Format}
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

        # get log path (and create it if blabla.....)
        $Configuration.Path = Get-LogPath -CallingScriptPath $Log.pathname -Path $Configuration.Path -CallerShortcut $Script:Logging.CallerShortcut

        $Text = "$(Replace-Token -String $Configuration.Format -Source $Log) $Text"

        $Params = @{
            Append      = $Configuration.Append
            FilePath    = Replace-Token -String $Configuration.Path -Source $Log
            Encoding    = $Configuration.Encoding
        }

        Write-Verbose "[Logger/File] Logging to: $($Params.FilePath)"
        $Text | Out-File @Params
    }
}