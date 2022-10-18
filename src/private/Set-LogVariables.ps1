function Set-LogVariables
{

    #Already setup
    if ($Script:Logging -and $Script:LevelNames)
    {
        return
    }

    Write-Verbose -Message 'Setting up vars'

    $Script:NOTSET = 0
    $Script:DEBUG = 10
    $Script:INFO = 20
    $Script:SUCCESS = 25
    $Script:WARNING = 30
    $Script:ERROR_ = 40

    $Script:NONE = 0
    $Script:WEEK = 1
    $Script:MONTH = 2
    $Script:YEAR = 3

    New-Variable -Name LevelNames           -Scope Script -Option ReadOnly -Value ([hashtable]::Synchronized(@{
        $NOTSET   = 'NOTSET'
        $ERROR_   = 'ERROR'
        $WARNING  = 'WARNING'
        $INFO     = 'INFO'
        $DEBUG    = 'DEBUG'
        $SUCCESS  = 'SUCCESS'
        'NOTSET'  = $NOTSET
        'ERROR'   = $ERROR_
        'WARNING' = $WARNING
        'INFO'    = $INFO
        'DEBUG'   = $DEBUG
        'SUCCESS' = $SUCCESS
    }))

    New-Variable -Name RolloverTypes             -Scope Script -Option ReadOnly -Value ([hashtable]::Synchronized(@{
        'NONE'  = $NONE
        'WEEK'  = $WEEK
        'MONTH' = $MONTH
        'YEAR'  = $YEAR
    }))

    New-Variable -Name ScriptRoot           -Scope Script -Option ReadOnly -Value ([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Module.Path))
    New-Variable -Name Defaults             -Scope Script -Option ReadOnly -Value @{
        Level           = 'INFO'
        LevelNo         = $LevelNames['INFO']
        Format          = '[%timestamp%] [%level%] - %message%'
        Timestamp       = 'dd.MM.yyyy HH:mm:ss'
        CallerScope     = 1
        CallerShortcut  = '%1'
        RolloverType    = $RolloverTypes['NONE']
    }

    New-Variable -Name Logging              -Scope Script -Option ReadOnly -Value ([hashtable]::Synchronized(@{
        Level          = $Defaults.Level
        LevelNo        = $Defaults.LevelNo
        Format         = $Defaults.Format
        CallerScope    = $Defaults.CallerScope
        CallerShortcut = $Defaults.CallerShortcut
        RolloverType   = $RolloverTypes['NONE']
        CustomTargets  = [String]::Empty
        Targets        = ([System.Collections.Concurrent.ConcurrentDictionary[string, hashtable]]::new([System.StringComparer]::InvariantCultureIgnoreCase))
        EnabledTargets = ([System.Collections.Concurrent.ConcurrentDictionary[string, hashtable]]::new([System.StringComparer]::InvariantCultureIgnoreCase))
    }))
}