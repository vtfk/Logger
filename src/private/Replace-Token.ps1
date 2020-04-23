function Replace-Token {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
    [CmdletBinding()]
    param(
        [string] $String,
        [object] $Source
    )

    foreach($key in $Source.Keys)
    {
        if ($key -match "body|exception")
        {
            continue;
        }

        $value = $source[$key]
        if ($null -eq $value)
        {
            $value = ""
        }

        $String = $String.Replace("%$key%", $value)
    }

    return $String
}