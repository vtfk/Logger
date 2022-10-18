function Get-RolloverPath {
    param(
        [Parameter(Mandatory = $True)]
        [string]$Path,

        [Parameter(Mandatory = $True)]
        [string]$Type
    )

    $file = Split-Path -Path $Path -Leaf

    if ($Type -eq "WEEK") {
        $file = "$([System.IO.Path]::GetFileNameWithoutExtension($file))_$((Get-Date).DayOfWeek.ToString().ToLower())$([System.IO.Path]::GetExtension($file))"
    }
    elseif ($Type -eq "MONTH") {
        $file = "$([System.IO.Path]::GetFileNameWithoutExtension($file))_$(Get-Date -UFormat "%d")_$([System.IO.Path]::GetExtension($file))"
    }
    elseif ($Type -eq "YEAR") {
        $file = "$([System.IO.Path]::GetFileNameWithoutExtension($file))_$(Get-Date -UFormat "%b_%d")_$([System.IO.Path]::GetExtension($file))"
    }

    $Path = "$(Split-Path -Path $Path -Parent)\$file"

    return $Path
}