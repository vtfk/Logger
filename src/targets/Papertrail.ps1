@{
    Name = 'Papertrail'
    Configuration = @{
        Server          = @{Required = $false;  Type = [string];    Default = "logs.papertrailapp.com"}
        Port            = @{Required = $true;   Type = [int];       Default = 0}
        HostName        = @{Required = $true;   Type = [string];    Default = $null}
        Facility        = @{Required = $false;  Type = [string];    Default = 'syslog'}
        Level           = @{Required = $false;  Type = [string];    Default = $Logging.Level}
        Sanitize        = @{Required = $false;  Type = [bool];      Default = $false}
        SanitizeMask    = @{Required = $false;  Type = [char];      Default = '*'}
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

        # Define Hostname, if set to '-', or not set at all, the POSH-syslog module will set this to $env:COMPUTERNAME
        if ($Configuration.HostName) { $hostname = $Configuration.HostName }
        else { $hostname = "-" }

        # Define ApplicationName, if set to '-' or not at all, the POSH-syslog module will set this to the closest name in the call stack
        $applicationName = "default"

        # Define Severity and Level
        switch ($Log.LevelNo)
        {
            {$_ -ge 40}                { $Severity = "Error";         $Level = "ERROR" }
            {$_ -ge 30 -and $_ -lt 40} { $Severity = "Warning";       $Level = "WARN" }
            {$_ -lt 30 -and $_ -gt 10} { $Severity = "Informational"; $Level = "INFO" }
            {$_ -le 10 -and $_ -gt 0}  { $Severity = "Debug";         $Level = "DEBUG" }
        }

        # Make sure Severity and Level is setup
        if (!$Severity) { $Severity = "Informational" }
        if (!$Level) { $Level = "INFO" }
        
        # Create Message
        [string]$Message = "$Level - "
        if ($Log.filename) { $Message += "$($Log.filename) - " }
        if ($Log.caller -and $Log.caller -ne $Log.filename) { $Message += "$($Log.caller) - " }
        $Message += $Log.Message

        # Sanitize message
        if ($Configuration.Sanitize)
        {
            $Message = Get-SanitizedMessage -Message $Log.Message -Mask $Configuration.SanitizeMask
        }

        # If an object is defined, add object to message in json format.
        if ($Log.Body)
        {
            $Message += " - Body: $($Log.Body | Out-String)"
        }

        # if an exception is defined, add object to message in json format.
        if ($Log.Exception)
        {
            [string]$exception = ""

            if ($Log.Exception.PSobject.Properties.name -match "InvocationInfo")
            {
                Write-Verbose "[Logger\Papertrail] :: InvocationInfo"
                $exception = $Log.Exception.InvocationInfo.PositionMessage
            }

            if ($Log.Exception.PSobject.Properties.name -match "Exception")
            {
                Write-Verbose "[Logger\Papertrail] :: Exception"
                $exception = $Log.Exception.Exception
            }

            $Message += " - Exception: $($exception)"
        }
        
        $Params = @{
            Server          = $Configuration.Server
            Port            = $Configuration.Port
            Message         = $Message
            Severity        = $Severity
            ApplicationName = $applicationName
            HostName        = $hostname
            Facility        = $Configuration.Facility
        }

        # Write SysLogMessage
        Write-Verbose "[Logger/Papertrail] Logging to: $($Params.Server)@$($Params.Port)"
        Send-SyslogMessage @Params
    }
}
