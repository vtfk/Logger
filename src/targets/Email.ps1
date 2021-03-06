﻿@{
    Name = 'Email'
    Description = 'Send log message to email recipients'
    Configuration = @{
        SMTPServer   = @{Required = $true;   Type = [string];                Default = $null}
        From         = @{Required = $true;   Type = [string];                Default = $null}
        To           = @{Required = $true;   Type = [string];                Default = $null}
        Subject      = @{Required = $false;  Type = [string];                Default = '[%level%] %message%'}
        BodyAsHtml   = @{Required = $false;  Type = [bool];                  Default = $true}
        Encoding     = @{Required = $false;  Type = [System.Text.Encoding];  Default = [System.Text.Encoding]::UTF8}
        Credential   = @{Required = $false;  Type = [pscredential];          Default = $null}
        Level        = @{Required = $false;  Type = [string];                Default = $Logging.Level}
        Port         = @{Required = $false;  Type = [int];                   Default = 25}
        UseSsl       = @{Required = $false;  Type = [bool];                  Default = $false}
        Format       = @{Required = $false;  Type = [string];                Default = $Logging.Format}
        Sanitize     = @{Required = $false;  Type = [bool];                  Default = $false}
        SanitizeMask = @{Required = $false;  Type = [char];                  Default = '*'}
    }
    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        if ($Log.Body -and $Log.Body.Subject) {
            $subject = $Log.Body.Subject
            $Log.Body.Remove("Subject")
        }
        else {
            $subject = Replace-Token -String $Configuration.Subject -Source $Log
        }

        $Params = @{
            SmtpServer = $Configuration.SMTPServer
            From = $Configuration.From
            To = $Configuration.To.Split(',').Trim()
            BodyAsHtml = $Configuration.BodyAsHtml
            Port = $Configuration.Port
            UseSsl = $Configuration.UseSsl
            Subject = if ($Configuration.Sanitize) { Get-SanitizedMessage -Message $subject -Mask $Configuration.SanitizeMask } else { $subject }
        }

        if ($Configuration.Encoding) {
            $Params['Encoding'] = $Configuration.Encoding
        }

        if ($Configuration.Credential) {
            $Params['Credential'] = $Configuration.Credential
        }

        if ($Log.Body -and $Log.Body.Count -gt 0) {
            [string]$body = Replace-Token -String '%message%' -Source $Log
            if ($Configuration.BodyAsHtml) {
                $body += "<br><br>`n"
            }
            else {
                $body += "`n`n"
            }
            
            $Params.Body = "$body $($Log.Body | ConvertTo-Json)"
        }
        else {
            $body = Replace-Token -String $Configuration.Format -Source $Log
            if ($Configuration.Sanitize) {
                $Params.Body = Get-SanitizedMessage -Message $body -Mask $Configuration.SanitizeMask
            }
            else {
                $Params.Body = $body
            }
        }

        Send-MailMessage @Params
    }
}
