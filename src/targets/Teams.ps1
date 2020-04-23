@{
    Name = 'Teams'
    Configuration = @{
        WebHook     = @{Required = $true;  Type = [string]; Default = $null}
        Level       = @{Required = $false; Type = [string]; Default = $Logging.Level}
        Format      = @{Required = $false; Type = [string]; Default = "%message%"}
        ColorMapping = @{Required = $false; Type = [hashtable]; Default = @{
                                                            'DEBUG'   = '999999'
                                                            'INFO'    = '0087ff'
                                                            'WARNING' = 'ffdd00'
                                                            'ERROR'   = 'ff0000'
                                                        }}
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

        $Text = @{
            '@type' = "MessageCard"
            '@context' = "https://schema.org/extensions"
            summary = "$($Log.level): $(Replace-Token -String $Configuration.Format -Source $Log)"
            text = Replace-Token -String $Configuration.Format -Source $Log
            sections = @()
        }

        if ($Configuration.ColorMapping[$Log.Level]) {
            $Text['themeColor'] = $Configuration.ColorMapping[$Log.Level]
        } else {
            $Text['themeColor'] = 'ffffff'
        }

        # If an object or exception is defined, add object to message in json format.
        if ($Log.Body)
        {
            $Text['sections'] += @{ title = "**Body**"; text = "$($Log.Body | ConvertTo-Json -Depth 10)" }
        }
        if ($Log.Exception)
        {
            $Exception = $Log.Exception
            if($Exception.PSobject.Properties.name -match "Exception")
            {
                $Exception = $Log.Exception.Exception
            }

            $errorDetails = @()

            if($Exception.PSobject.Properties.name -match "Message")
            {
                $errorDetails += @{ Name  = "Message"; Value = $Exception.Message }
            }

            if($Exception.PSobject.Properties.name -match "InnerException" -and $Exception.InnerException)
            {
                $errorDetails += @{ Name  = "InnerException"; Value = "$($Exception.InnerException)" }
            }

            if($Exception.PSobject.Properties.name -match "StackTrace")
            {
                $errorDetails += @{ Name  = "StackTrace"; Value = "$($Exception.StackTrace.Replace("at ", "`nat "))" }
            }

            $Text['sections'] += @{ title = "**Exception**"; facts = $errorDetails }
        }

        Invoke-RestMethod -Method POST -Uri $Configuration.WebHook -ContentType "application/json; charset=utf-8" -Body ($Text | ConvertTo-Json -Depth 5) -ErrorAction SilentlyContinue | Out-Null
    }
}