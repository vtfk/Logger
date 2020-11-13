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
$ git clone https://github.com/vtfk/Logging
```

## Example Usage

```powershell
Import-Module /path/to/cloned/repository

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
| [Console](https://github.com/EsOsO/Logging/wiki/Console) | Writes log messages to the console.  |
| [File](https://github.com/EsOsO/Logging/wiki/File) | Logs to file. If the file or directory doesn't exist, it will be created. |
| [EventLog](https://github.com/EsOsO/Logging/wiki/WinEventLog) | Logs to EventLog. <br>Before you can log events you need to make sure that the LogName and Source exists. This needs to be done only once (run as an Administrator): <br>``$ New-EventLog -LogName <Application/System/...> -Source ScriptName``  |
| [Teams](https://github.com/EsOsO/Logging/wiki/Teams) | Sends the log message to Microsoft Teams. Pass the [incomming webhook URL](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook#add-an-incoming-webhook-to-a-teams-channel) in the configuration. |
| [Slack](https://github.com/EsOsO/Logging/wiki/Slack) | Sends the log message to Slack. Create an app in Slack, and pass the [incomming webhook URL](https://api.slack.com/messaging/webhooks#getting_started) in the configuration. |
| CMTrace | Logs to file as described above, but in the [CMTrace](https://docs.microsoft.com/en-us/mem/configmgr/core/support/cmtrace) format. |
| Archeo | Logs to [Archeo](https://archeo.communicate.no/). Remember to set ``ApiKey``, ``TransactionId``, ``TransactionType`` and ``TransactionTag`` in the target configuration. |



## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](LICENSE)
