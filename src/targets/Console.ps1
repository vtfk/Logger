@{
    Name = 'Console'
    Description = 'Writes messages to console with different colors.'
    Configuration = @{
        Level        = @{Required = $false; Type = [string];    Default = $Logging.Level}
        Format       = @{Required = $false; Type = [string];    Default = $Logging.Format}
        ColorMapping = @{Required = $false; Type = [hashtable]; Default = @{
                                                                    'DEBUG'   = 'Grey'
                                                                    'INFO'    = 'Cyan'
                                                                    'WARNING' = 'Yellow'
                                                                    'ERROR'   = 'Red'
                                                                    'SUCCESS' = 'Green'
                                                                }
        }
    }
    Init = {
        param(
            [hashtable] $Configuration
        )

        foreach ($Level in $Configuration.ColorMapping.Keys) {
            $Color = $Configuration.ColorMapping[$Level]

            if ($Color -notin ([System.Enum]::GetNames([System.ConsoleColor]))) {
                Write-Error "ERROR: Cannot use custom color '$Color': not a valid [System.ConsoleColor] value"
                continue
            }
        }
    }
    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        try {
            $logText = Replace-Token -String $Configuration.Format -Source $Log

            if (![String]::IsNullOrWhiteSpace($Log.Exception)) {
                $logText += "`n" + $Log.Exception.InvocationInfo.PositionMessage
            }

            if ($Configuration.ColorMapping.ContainsKey($Log.Level)) {
                Write-Host $logText -ForegroundColor $Configuration.ColorMapping[$Log.Level]
            } else {
                Write-Host $logText
            }

        }
        catch {
            Write-Error $_
        }
    }
}