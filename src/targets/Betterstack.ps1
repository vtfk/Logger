@{
    Name = 'Betterstack'
    Configuration = @{
        Url             = @{Required = $true;  Type = [string]; }
        Token           = @{Required = $false;   Type = [string];    Default = $null}
        HostName        = @{Required = $false;   Type = [string];    Default = $null}
        Level           = @{Required = $false;  Type = [string];    Default = $Logging.Level}
        Sanitize        = @{Required = $false;  Type = [bool];      Default = $false}
        SanitizeMask    = @{Required = $false;  Type = [char];      Default = '*'}
    }

    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        if (!$Configuration.Url.StartsWith("https")) {
            Write-Error -Message "Server must be a valid URI" -ErrorAction Stop
        }
<#  #>
        # Default prefix for HostName
        $hostNamePrefix = "PS"

        if ($Log.Verbose)
        {
            $VerbosePreference = "Continue"
        }

        # Define Hostname, if set to '-', or not set at all, the POSH-syslog module will set this to $env:COMPUTERNAME
        if ($Configuration.HostName -and !$Configuration.HostName.StartsWith("$($hostNamePrefix)-")) {
            $hostname = "$($hostNamePrefix)-$($Configuration.HostName)"
        }
        elseif ($Configuration.HostName -and $Configuration.HostName.StartsWith("$($hostNamePrefix)-")) {
            $hostname = $Configuration.HostName
        }
        else { $hostname = $hostNamePrefix }

        # Define ApplicationName, if set to '-' or not at all, the POSH-syslog module will set this to the closest name in the call stack
        $applicationName = "default"

        # Define Severity and Level
        switch ($Log.LevelNo)
        {
            {$_ -ge 40}                { $Severity = "Error";         $Level = "ERROR" }
            {$_ -ge 30 -and $_ -lt 40} { $Severity = "Warning";       $Level = "WARN" }
            {$_ -lt 30 -and $_ -ge 25} { $Severity = "Informational"; $Level = "SUCCESS" }
            {$_ -lt 25 -and $_ -gt 10} { $Severity = "Informational"; $Level = "INFO" }
            {$_ -le 10 -and $_ -gt 0}  { $Severity = "Debug";         $Level = "DEBUG" }
        }

        # Make sure Severity and Level is setup
        if (!$Severity) { $Severity = "Informational" }
        if (!$Level) { $Level = "INFO" }

        # Create Message
        [string]$Message = "$Level - "
        if ($Log.filename) { $Message += "$($Log.filename) - " }
        if ($Log.caller -and $Log.caller -ne $Log.filename) { $Message += "$($Log.caller) - " }
        if ($Configuration.Token -and $Configuration.HostName) { $Message += "$($Configuration.HostName) - " }
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
                Write-Verbose "[Logger\Betterstack] :: InvocationInfo"
                $exception = $Log.Exception.InvocationInfo.PositionMessage
            }

            if ($Log.Exception.PSobject.Properties.name -match "Exception")
            {
                Write-Verbose "[Logger\Betterstack] :: Exception"
                $exception = $Log.Exception.Exception
            }

            $Message += " - Exception: $($exception)"
        }

        # Write LogMessage
        Write-Verbose "[Logger/Betterstack/HTTP] Logging to: $($Configuration.Url)"
        $Message = @{message = $Message} | ConvertTo-Json
             
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # OMG, this is needed for the Invoke-RestMethod to work with TLS 1.2
        try{
            Invoke-RestMethod -Method "POST" -Uri $Configuration.Url -Headers @{ 'Authorization' = "Bearer $($Configuration.Token)"; 'Content-Type' = "application/json" } -Body $Message | Out-Null #-ErrorAction SilentlyContinue
           
        } catch {
            Write-Error -Message "Failed to send log to Betterstack: $temp" -ErrorAction Stop
        }
    }
}
