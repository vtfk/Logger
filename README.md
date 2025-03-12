# Logger

Modular PowerShell logging module, forked from [EsOsO/Logging](https://github.com/EsOsO/Logging).

This version runs synchronous, because we are having issues running the original module (that creates multiple runspaces) in our environment.
If you want to log asynchronous, please use the original version over at [EsOsO/Logging](https://github.com/EsOsO/Logging).


## Installation

### System Environment Variables

Create two variables:

1. SCRIPT_DIR = **Path-to-folder-containing-all-script-repos**
1. LOG_DIR = **Path-to-folder-containing-all-logging**

### Source

Clone this repository, and then import the folder using ``Import-Module $Path`` 

```bash
$ git clone https://github.com/vtfk/Logger
```

## Example Usage for testing

```powershell
Import-Module /path/to/cloned/repository/Logger.psm1

# Adds the Console target to make Write-Log output to Console. 
Add-LogTarget -Name Console 

Write-Log "Hello World!"

try {
  # Execute something here...
  Write-Log "Executed something successfully!" -Level SUCCESS
} catch {
  Write-Log "Something failed! :(" -Level ERROR -Exception $_
}

# will replace shortcut (%1) with the actual name of the calling script
Add-LogTarget -Name CMtrace -Configuration @{ Path = "%1_Test.log" }
```

For more examples, please take a quick look at [example.ps1](https://github.com/vtfk/Logger/blob/master/Example.ps1) or head over to [EsOsO/Logging's wiki](https://github.com/EsOsO/Logging/wiki).

## Set up global module on server
Clone this repository or sync it if you already have it

```bash
$ git clone https://github.com/vtfk/Logger
```

- Check PSModule path in system environment variables (`$env:PSModulePath`)
- Check if you already have a folder in the PSModule path called "Logger" - if not create it
- Copy the contents of the src folder into Logger directory

You should now be able to use
```powershell
Import-Module Logger
```
In your ps1 script


## Sanitizing log message

Almost all targets have the possibility to turn on sanitizing of log message.  Sanitizing will mask up:
* Bank account numbers
* Credit card numbers
* Social security numbers

```powershell
Import-Module /path/to/cloned/repository

Add-LogTarget -Name File -Configuration @{ Sanitize = $True }

Write-Log -Message "Some message with social number: 01234567891"
```

**Sanitizing is only available for Norwegian info** - Pull requests for other types/languages are welcome.


## Log targets
| Log Target  | Description |
| ----------- | ----------- |
| CMTrace | Logs to file as described above, but in the [CMTrace](https://docs.microsoft.com/en-us/mem/configmgr/core/support/cmtrace) format. |
| [Console](https://github.com/EsOsO/Logging/wiki/Console) | Writes log messages to the console.  |
| [Email](https://github.com/EsOsO/Logging/wiki/Email) | Send an email with preconfigured subject, from and to. Pass along a `-Body` on `Write-Log` to add more content to mail body |
| [EventLog](https://github.com/EsOsO/Logging/wiki/WinEventLog) | Logs to EventLog. <br>Before you can log events you need to make sure that the LogName and Source exists. This needs to be done only once (run as an Administrator): <br>``$ New-EventLog -LogName <Application/System/...> -Source ScriptName``  |
| [File](https://github.com/EsOsO/Logging/wiki/File) | Logs to file. If the file or directory doesn't exist, it will be created. |
| [Papertrail](https://github.com/vtfk/Logger#papertrail) | Logs to [Papertrail](https://www.papertrail.com/) |
| [Betterstack](https://github.com/vtfk/Logger#betterstack) | Logs to [Betterstack](https://www.betterstack.com/) |
| [Slack](https://github.com/EsOsO/Logging/wiki/Slack) | Sends the log message to Slack. Create an app in Slack, and pass the [incoming webhook URL](https://api.slack.com/messaging/webhooks#getting_started) in the configuration. |
| [Teams](https://github.com/EsOsO/Logging/wiki/Teams) | Sends the log message to Microsoft Teams. Pass the [incoming webhook URL](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook#add-an-incoming-webhook-to-a-teams-channel) in the configuration. |

## Log target options / examples

### CMTrace

`options`
```PowerShell
Path         = "AFileNameYouWant || %1_SomethingMore" # Configure the filename the way you want, optionally/additionally use the shortcut (%1)
Append       = $True || $False # Defaults to $True
Encondig     = "UTF8" # Defaults to utf8
Level        = "INFO" # Set at which level (and higher) this target will start to log. Defaults to INFO
Sanitize     = $True || $False # Turn sanitization on / off. Defaults to $False
SanitizeMask = "*" # Set which char to use for masked text. Defaults to "*"
RolloverType = "NONE || WEEK || MONTH || YEAR" # If set to other than NONE, Logger will automatically rollover logfile according to Type. Defaults to NONE
```

`example`
```PowerShell
Add-LogTarget -Name CMTrace -Configuration @{ Path = "Hey there"; Level = "INFO" }
Write-Log -Message "Message to log (will be logged to cmtrace file since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will also be logged to cmtrace file since this is logged with INFO level or higher" -Level WARNING
```

`example with Rollover`
```PowerShell
# If this is executed on a tuesday, this will be logged in a file named "Hey there_tuesday.log".
# If file name "Hey there_tuesday.log" already existed and is older than today, it will be removed before logged to
Add-LogTarget -Name CMTrace -Configuration @{ Path = "Hey there"; Level = "INFO"; RolloverType = "WEEK" }
Write-Log -Message "Message to log (will be logged to cmtrace file since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will also be logged to cmtrace file since this is logged with INFO level or higher" -Level WARNING
```

### Console

`options`
```PowerShell
Level        = "INFO" # Set at which level (and higher) this target will start to log. Defaults to INFO
Format       = "[%timestamp%] [%level%] - [%message%]" # Set which format to use for log output. Defaults to "[%timestamp%] [%level%] - [%message%]"
ColorMapping = @{ 'INFO' = "Cyan" } # Set which colors to use for each level. Defaults to @{ 'DEBUG' = 'Gray'; 'INFO' = 'Cyan'; 'WARNING' = 'Yellow'; 'ERROR' = 'Red'; 'SUCCESS' = 'Green' }
```

`example`
```PowerShell
Add-LogTarget -Name Console -Configuration @{ Level = "SUCCESS" }
Write-Log -Message "Message to log (will NOT be logged to console since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will be logged to console since this is logged with SUCCESS level or higher" -Level WARNING
```

### Email

`options`
```PowerShell
SMTPServer   = "INFO" # Set hostname to smtp server
From         = "noreply@vtfk.no" # Set the address mails will be sent from
To           = "someone@vtfk.no" # Set the address mails will be sent to
Subject      = "Somethings happening" # Set the subject for the mails sent
BodyAsHtml   = $True || $False # Set whether the messages logged will be treated as HTML. Defaults to $True
Encondig     = "UTF8" # Defaults to utf8
Credential   = [PSCredential] # Set PSCredentials if smtp server requires credentials
Level        = "INFO" # Set at which level (and higher) this target will start to log. Defaults to INFO
Port         = 25 # Set which port smtp server is using. Defaults to 25
UseSsl       = $True || $False # Set whether smtp server requires SSL. Defaults to $False
Format       = "[%timestamp%] [%level%] - [%message%]" # Set which format to use for log output. Defaults to "[%timestamp%] [%level%] - [%message%]"
Sanitize     = $True || $False # Turn sanitization on / off. Defaults to $False
SanitizeMask = "*" # Set which char to use for masked text. Defaults to "*"
```

`example`
```PowerShell
Add-LogTarget -Name Email -Configuration @{ SMTPServer = "smtp.server.com"; From = "noreply@vtfk.no"; To = "somedude@vtfk.no"; Subject = "Something is wrong"; BodyAsHtml = $True; Level = "WARNING" }
Write-Log -Message "Message to log (will NOT be sent by email since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will be sent by email since this is logged with WARNING level or higher" -Level ERROR
```

### EventLog

`options`
```PowerShell
LogName      = "Application" # Set which log name to log to. LogName must exist
Source       = "SoftwareName" # Set which source to group after. Source must exist
Level        = "INFO" # Set at which level (and higher) this target will start to log. Defaults to INFO
Sanitize     = $True || $False # Turn sanitization on / off. Defaults to $False
SanitizeMask = "*" # Set which char to use for masked text. Defaults to "*"
```

`example`
```PowerShell
Add-LogTarget -Name EventLog -Configuration @{ LogName = "Application"; Source = "Mindblowing Enterprise Application"; Level = "INFO" }
Write-Log -Message "Message to log (will be logged to EventLog since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will also be logged to EventLog since this is logged with INFO level or higher" -Level ERROR
```

### File

`options`
```PowerShell
Path         = "AFileNameYouWant || %1_SomethingMore" # Configure the filename the way you want, optionally/additionally use the shortcut (%1)
Append       = $True || $False # Defaults to $True
Encondig     = "UTF8" # Defaults to utf8
Level        = "INFO" # Set at which level (and higher) this target will start to log. Defaults to INFO
Format       = "[%timestamp%] [%level%] - [%message%]" # Set which format to use for log output. Defaults to "[%timestamp%] [%level%] - [%message%]"
Sanitize     = $True || $False # Turn sanitization on / off. Defaults to $False
SanitizeMask = "*" # Set which char to use for masked text. Defaults to "*"
RolloverType = "NONE || WEEK || MONTH || YEAR" # If set to other than NONE, Logger will automatically rollover logfile according to Type. Defaults to NONE
```

`example`
```PowerShell
Add-LogTarget -Name File -Configuration @{ Path = "Hey there"; Level = "INFO" }
Write-Log -Message "Message to log (will be logged to file since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will also be logged to file since this is logged with INFO level or higher" -Level WARNING
```

`example with Rollover`
```PowerShell
# If this is executed on a tuesday, this will be logged in a file named "Hey there_tuesday.log".
# If file name "Hey there_tuesday.log" already existed and is older than today, it will be removed before logged to
Add-LogTarget -Name File -Configuration @{ Path = "Hey there"; Level = "INFO"; RolloverType = "WEEK" }
Write-Log -Message "Message to log (will be logged to file since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will also be logged to file since this is logged with INFO level or higher" -Level WARNING
```

### Papertrail

`options`
```PowerShell
Server       = "logs.papertrailapp.com" # Set server to log to. Defaults to logs.papertrailapp.com
Port         = 0 # Set which port to use. Requires HostName aswell. Defaults to 0
HostName     = "SoftwareName" # Set which HostName to use. Requires Port aswell.
Token        = "secret" # Set the token used. HostName and Port will be ignored.
Facility     = "syslog" # Set which protocol to use when HostName:Port is used.
Level        = "INFO" # Set at which level (and higher) this target will start to log. Defaults to INFO
Sanitize     = $True || $False # Turn sanitization on / off. Defaults to $False
SanitizeMask = "*" # Set which char to use for masked text. Defaults to "*"
```

`example - HostName:Port`
```PowerShell
Add-LogTarget -Name PaperTrail -Configuration @{ Server = "logs.server.com"; Port = 1234; Hostname = "Systemname-this-log-will-be-added-to"; Level = "WARNING" }
Write-Log -Message "Message to log (will not be logged to papertrail since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will be logged to papertrail since this is logged with WARNING level or higher" -Level WARNING
```

`example - Token`
```PowerShell
Add-LogTarget -Name PaperTrail -Configuration @{ Server = "logs.server.com"; Token = "secret"; Level = "WARNING" }
Write-Log -Message "Message to log (will not be logged to papertrail since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will be logged to papertrail since this is logged with WARNING level or higher" -Level ERROR
```

### Betterstack

`options`
```PowerShell
Url          = "betterstack.com" # Set server to log to. Defaults to logs.papertrailapp.com
Token        = "secret" # Set the token for betterstack source.
HostName     = "SoftwareName" # Set which HostName to use. Requires Port aswell.
Level        = "INFO" # Set at which level (and higher) this target will start to log. Defaults to INFO
Sanitize     = $True || $False # Turn sanitization on / off. Defaults to $False
SanitizeMask = "*" # Set which char to use for masked text. Defaults to "*"
```

`example`
```PowerShell
Add-LogTarget -Name Betterstack -Configuration @{ Url = "betterstack.com"; Token = "secret"; Level = "WARNING" }
Write-Log -Message "Message to log (will not be logged to betterstack since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will be logged to betterstack since this is logged with WARNING level or higher" -Level ERROR
```

### Slack

`options`
```PowerShell
WebHook = "https://webhook-url-to-slack" # Set which url to use as webhook
BotName = "" # Set which name used for the Bot
Channel = "" # Set which channel logs will be sent to
Icons   = @{ 'INFO' = ":exclamation" } # Set which icons to use for each level. Defaults to @{ 'DEBUG' = ':eyes:'; 'INFO' = ':exclamation:'; 'WARNING' = ':warning:'; 'ERROR' = ':fire:' }
Level   = "INFO" # Set at which level (and higher) this target will start to log. Defaults to INFO
Format  = "[%timestamp%] [%level%] - [%message%]" # Set which format to use for log output. Defaults to "[%timestamp%] [%level%] - [%message%]"
```

`example`
```PowerShell
Add-LogTarget -Name Slack -Configuration @{ WebHook = "https://webhook-url-to-slack"; BotName = "Turid Laila"; Channel = "Norway"; Level = "WARNING" }
Write-Log -Message "Message to log (will not be logged to slack since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will be logged to slack since this is logged with WARNING level or higher" -Level WARNING
```

### Teams

`options`
```PowerShell
WebHook      = "https://webhook-url-to-teams" # Set which url to use as webhook
Level        = "INFO" # Set at which level (and higher) this target will start to log. Defaults to INFO
Format       = "[%timestamp%] [%level%] - [%message%]" # Set which format to use for log output. Defaults to "[%timestamp%] [%level%] - [%message%]"
ColorMapping = @{ 'INFO' = "Cyan" } # Set which colors to use for each level. Defaults to @{ 'DEBUG' = 'Gray'; 'INFO' = 'Cyan'; 'WARNING' = 'Yellow'; 'ERROR' = 'Red'; 'SUCCESS' = 'Green' }
Sanitize     = $True || $False # Turn sanitization on / off. Defaults to $False
SanitizeMask = "*" # Set which char to use for masked text. Defaults to "*"
```

`example`
```PowerShell
Add-LogTarget -Name Teams -Configuration @{ WebHook = "https://webhook-url-to-teams"; Level = "WARNING" }
Write-Log -Message "Message to log (will not be logged to teams since this is logged with INFO level" -Level INFO
Write-Log -Message "Message to log (will be logged to teams since this is logged with WARNING level or higher" -Level WARNING
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](LICENSE)
