function Get-RolloverType
{
    param(
        [Parameter(Mandatory = $True)]
        [string]$Type
    )

    return $Script:RolloverTypes[$Type]
}