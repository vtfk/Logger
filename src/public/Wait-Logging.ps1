Function Wait-Logging
{
    [CmdletBinding()]
    param()

    $ErrorMsg = "Cmdlet `"Wait-Logging`" is deprecated and should be removed!"
    
    Write-Log $ErrorMsg -Level WARNING
    Write-Warning $ErrorMsg
}