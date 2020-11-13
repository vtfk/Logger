@{
    Name = 'CMTrace'
    Configuration = @{
        Path         = @{Required = $false;  Type = [string];    Default = $null}
        Append       = @{Required = $false;  Type = [bool];      Default = $true}
        Encoding     = @{Required = $false;  Type = [string];    Default = 'utf8'}
        Level        = @{Required = $false;  Type = [string];    Default = $Logging.Level}
        Sanitize     = @{Required = $false;  Type = [bool];      Default = $false}
        SanitizeMask = @{Required = $false;  Type = [char];      Default = '*'}
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

        # Define CMTrace message fields
        if ($Log.caller) { $Component = $Log.caller } else { $Component = "" }
        if ($Log.filename) { $Program = $Log.filename } else { $Program = "" }
        $ComponentLineNumber = $Log.linenumber
        $Message = $Log.message
        if ($Configuration.Sanitize)
        {
            $Message = Get-SanitizedMessage -Message $Log.message -Mask $Configuration.SanitizeMask
        }
        $Thread = $Log.pid

        switch ($Log.LevelNo)
        {
            {$_ -ge 40}                { $Severity = 3 }
            {$_ -ge 30 -and $_ -lt 40} { $Severity = 2 }
            {$_ -lt 30}                { $Severity = 1 }
        }

        if($Log.level -notmatch "INFO|WARNING|ERROR")
        {
            $Severity = 1
            $Message = "$($Log.level.toUpper()): $Message"
        }

        # Construct datetime into cmtrace format
        $timeZoneBias = Get-WmiObject -Query "Select Bias from Win32_TimeZone" -ComputerName $env:COMPUTERNAME
        $date1 = Get-Date -Format "HH:mm:ss.fff"
        $date2 = Get-Date -Format "MM-dd-yyyy"
        $date3 = $date1.Substring(0, 8).Replace('.', ':')
        $date1 = "$date3$($date1.Substring(8, 4))"

        # If an object is defined, add object to message in json format.
        if ($Log.Body)
        {
            $Message += "`n - Body:`n   $($Log.Body | ConvertTo-Json)"
        }

        # if an exception is defined, add object to message in json format.
        if ($Log.Exception)
        {
            [string]$exception = ""

            if ($Log.Exception.PSobject.Properties.name -match "InvocationInfo")
            {
                Write-Verbose "[Logger\CMTrace] :: InvocationInfo"
                $exception += "`n$($Log.Exception.InvocationInfo.PositionMessage)"
            }

            if ($Log.Exception.PSobject.Properties.name -match "Exception")
            {
                Write-Verbose "[Logger\CMTrace] :: Exception"
                $exception += "`n`n$($Log.Exception.Exception)"
            }

            $Message += "`n - Exception:`n   $($exception)"
        }

        # Component not set - use line number instead.
        if (!$Component)
        {
            Write-Verbose "[Logger/CMTrace] Component not set. Using ComponentLineNumber ($ComponentLineNumber)"
            $Component = "LineNumber: $ComponentLineNumber"
        }

        # construct cmtrace log format
        $Text = "<![LOG[$Message]LOG]!><time=`"$date1+$($timeZoneBias.bias)`" date=`"$date2`" component=`"$Component`" context=`"`" type=`"$Severity`" thread=`"$Thread`" file=`"$Program`">"

        # pathname (ScriptName) must exist for logging to work
        if ($Log.pathname) {
            # get log path (and create it if blabla.....)
            $Configuration.Path = Get-LogPath -CallingScriptPath $Log.pathname -Path $Configuration.Path -CallerShortcut $Script:Logging.CallerShortcut
            
            $Params = @{
                Append      = $Configuration.Append
                FilePath    = Replace-Token -String $Configuration.Path -Source $Log
                Encoding    = $Configuration.Encoding
            }

            # output to logfile
            Write-Verbose "[Logger/CMTrace] Logging to: $($Params.FilePath)"
            $Text | Out-File @Params
        }
        else {
            Write-Warning "$Text :: Filepath not found (CallStack lacks necessary info)"
        }
    }
}
