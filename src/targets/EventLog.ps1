@{
    Name = 'EventLog'
    Configuration = @{
        LogName      = @{Required = $true;  Type = [string];  Default = $null}
        Source       = @{Required = $true;  Type = [string];  Default = $null}
        Level        = @{Required = $false;  Type = [string]; Default = $Logging.Level}
        Sanitize     = @{Required = $false; Type = [bool];    Default = $false}
        SanitizeMask = @{Required = $false;  Type = [char];   Default = '*'}
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

        $Params = @{
            EventId = 0
        }

        if ($Configuration.LogName) { $Params['LogName'] = $Configuration.LogName }
        if ($Configuration.Source)  { $Params['Source']  = $Configuration.Source }
        if ($Log.Body.EventId)      { $Params['EventId'] = $Log.Body.EventId }

        switch ($Log.LevelNo) {
            {$_ -ge 40}                { $Params['EntryType'] = 'Error' }
            {$_ -ge 30 -and $_ -lt 40} { $Params['EntryType'] = 'Warning' }
            {$_ -lt 30}                { $Params['EntryType'] = 'Information' }
        }

        $Params['Message'] = if ($Configuration.Sanitize) { Get-SanitizedMessage -Message $Log.Message -Mask $Configuration.SanitizeMask } else { $Log.Message }

        if ($Log.ExecInfo) {
            $ExceptionFormat = "{0}`n" +
                               "{1}`n" +
                               "+     CategoryInfo          : {2}`n" +
                               "+     FullyQualifiedErrorId : {3}`n"

            $ExceptionFields = @($Log.ExecInfo.Exception.Message,
                               $Log.ExecInfo.InvocationInfo.PositionMessage,
                               $Log.ExecInfo.CategoryInfo.ToString(),
                               $Log.ExecInfo.FullyQualifiedErrorId)

            if ( [string]::IsNullOrEmpty($Params['Message']) ){
                $Params['Message'] = $ExceptionFormat -f $ExceptionFields
            } else {
                $Params['Message'] += "`n`n" + ($ExceptionFormat -f $ExceptionFields)
            }
        }

        Write-EventLog @Params
    }
}
