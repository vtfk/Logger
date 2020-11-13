@{
    Name          = 'WebexTeams'
    Configuration = @{
        BotToken     = @{Required = $true; Type = [string]; Default = $null }
        RoomID       = @{Required = $true; Type = [string]; Default = $null }
        Icons        = @{Required = $false; Type = [hashtable]; Default = @{
                'ERROR'   = '🚨'
                'WARNING' = '⚠️'
                'INFO'    = 'ℹ️'
                'DEBUG'   = '🔎'
            }
        }
        Level        = @{Required = $false; Type = [string]; Default = $Logging.Level }
        Format       = @{Required = $false; Type = [string]; Default = $Logging.Format }
        Sanitize     = @{Required = $false; Type = [bool];   Default = $false}
        SanitizeMask = @{Required = $false;  Type = [char];  Default = '*'}
    }
    Logger        = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        # Build the Message body
        $text = Replace-Token -String $Configuration.Format -Source $Log
        $body = @{
            roomId = $Configuration.RoomId
            text   = $Configuration.Icons[$Log.Level] + " " + $(if ($Configuration.Sanitize) { Get-SanitizedMessage -Message $text -Mask $Configuration.SanitizeMask } else { $text })
        }

        # Convert to JSON
        $json = $body | ConvertTo-Json
        # Send Message to Cisco Webex API - UTF8 Handling for Emojiis
        Invoke-RestMethod -Method Post `
            -Headers @{"Authorization" = "Bearer $($Configuration.BotToken)" } `
            -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) `
            -Uri "https://api.ciscospark.com/v1/messages"
    }
}
