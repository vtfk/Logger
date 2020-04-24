function Get-LevelName
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [int] $Level
    )

    $l = $Script:LevelNames[$Level]
    if ($l)
    {
        return $l
    }
    else
    {
        return ('Level {0}' -f $Level)
    }
}
