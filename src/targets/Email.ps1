﻿@{
    Name = 'Email'
    Description = 'Send log message to email recipients'
    Configuration = @{
        SMTPServer   = @{Required = $true;   Type = [string];        Default = $null}
        From         = @{Required = $true;   Type = [string];        Default = $null}
        To           = @{Required = $true;   Type = [string];        Default = $null}
        Subject      = @{Required = $false;  Type = [string];        Default = '[%{level:-7}] %{message}'}
        Credential   = @{Required = $false;  Type = [pscredential];  Default = $null}
        Level        = @{Required = $false;  Type = [string];        Default = $Logging.Level}
        Port         = @{Required = $false;  Type = [int];           Default = 25}
        UseSsl       = @{Required = $false;  Type = [bool];          Default = $false}
        Format       = @{Required = $false;  Type = [string];        Default = $Logging.Format}
        Sanitize     = @{Required = $false;  Type = [bool];          Default = $false}
        SanitizeMask = @{Required = $false;  Type = [char];          Default = '*'}
    }
    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        $subject = Replace-Token -String '[%level%] %message%' -Source $Log
        $body = Replace-Token -String $Configuration.Format -Source $Log
        $Params = @{
            SmtpServer = $Configuration.SMTPServer
            From = $Configuration.From
            To = $Configuration.To.Split(',').Trim()
            Port = $Configuration.Port
            UseSsl = $Configuration.UseSsl
            Subject = if ($Configuration.Sanitize) { Get-SanitizedMessage -Message $subject -Mask $Configuration.SanitizeMask } else { $subject }
            Body = if ($Configuration.Sanitize) { Get-SanitizedMessage -Message $body -Mask $Configuration.SanitizeMask } else { $body }
        }

        if ($Configuration.Credential) {
            $Params['Credential'] = $Configuration.Credential
        }

        if ($Log.Body) {
            $Params.Body += "`n`n{0}" -f ((if ($Configuration.Sanitize) { Get-SanitizedMessage -Message $Log.Body -Mask $Configuration.SanitizeMask } else { $Log.Body }) | ConvertTo-Json)
        }

        Send-MailMessage @Params
    }
}
