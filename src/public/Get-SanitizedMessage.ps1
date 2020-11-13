<#
    .SYNOPSIS
        Sanitize message for "Bank account numbers", "Credit card numbers" and "Social security numbers"
    .DESCRIPTION
        Sanitize message for "Bank account numbers", "Credit card numbers" and "Social security numbers"
    .EXAMPLE
        Get-SanitizedMessage -Message "This is my social security number (01234567891)"
        Will sanitize message with * as masked character
    .EXAMPLE
        Get-SanitizedMessage -Message "This is my social security number (01234567891)" -Mask '%'
        Will sanitize message with % as masked character
    .EXAMPLE
        Get-SanitizedMessage -Message "This is my social security number (01234567891)" -BankAccountNumber $False -CreditCardNumber $False
        Will sanitize message (only for "Social security numbers") with * as masked character
#>
Function Get-SanitizedMessage
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [string]$Message,

        [Parameter()]
        [bool]$SocialSecurityNumber = $True,

        [Parameter()]
        [bool]$CreditCardNumber = $True,

        [Parameter()]
        [bool]$BankAccountNumber = $True,

        [Parameter()]
        [ValidatePattern("[^0-9]")]
        [char]$Mask = '*'
    )

    $regexPatterns = @(
        @{
            name = "Bank account number"
            pattern = "(\d{4}) (\d{2}) (\d{5})"
            replacement = "$((1..4 | % { "$Mask" }) -join '') $((1..2 | % { $Mask }) -join '') $((1..2 | % { $Mask }) -join '')ddd"
        },
        @{
            name = "Credit card number (no spaces)"
            pattern = "\d{16}"
            replacement = "$((1..12 | % { $Mask }) -join '')dddd"
        },
        @{
            name = "Credit card number (with spaces)"
            pattern = "(\d{4}) (\d{4}) (\d{4}) (\d{4})"
            replacement = "$((1..4 | % { $Mask }) -join '') $((1..4 | % { $Mask }) -join '') $((1..4 | % { $Mask }) -join '') dddd"
        },
        @{
            name = "Social security number"
            pattern = "\d{11}"
            replacement = "dddddd$((1..5 | % { $Mask }) -join '')"
        }
    )

    foreach ($regexPattern in $regexPatterns) {
        if (($regexPattern.name -like "bank account*" -and !$BankAccountNumber) -or
            ($regexPattern.name -like "credit card*" -and !$CreditCardNumber) -or
            ($regexPattern.name -like "social*" -and !$SocialSecurityNumber)) {
                Write-Verbose "Skipping '$($regexPattern.name)'"
            continue;
        }

        Clear-Variable -Name "regexMatches" -Force -Confirm:$False -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        
        $regexMatches = ([regex]$regexPattern.pattern).Matches($Message)
        if ($regexMatches.Count -gt 0) {
            
            :matchesLoop foreach ($regexMatch in $regexMatches) {
                [string]$sanitizedMatch = ""

                # making sure current match isn't inside another string
                $currentIndex = 0
                do {
                    $index = $Message.IndexOf($regexMatch.Value, $currentIndex)
                    $currentIndex = ($index + 1)
                    $previousIndex = ($index - 1)
                    $nextIndex = ($index + $regexMatch.Value.Length)

                    if ($index -gt 0) {
                        $previousIndexChar = $Message[$previousIndex]
                        if ($previousIndexChar -match "[a-zæøå]|[A-ZÆØÅ]|[0-9]|['`"]") {
                            Write-Verbose "Match is inside another string. Skipping"
                            continue matchesLoop;
                        }

                        if ($nextIndex -le $Message.Length) {
                            $nextIndexChar = $Message[$nextIndex]
                            if ($nextIndexChar -match "[a-zæøå]|[A-ZÆØÅ]|[0-9]|['`"]") {
                                Write-Verbose "Match is inside another string. Skipping"
                                continue matchesLoop;
                            }
                        }
                    }
                } while ($index -gt -1)

                for ($i = 0; $i -lt $regexMatch.Value.Length; $i++) {
                    if ($regexPattern.replacement[$i] -eq $Mask) {
                        $sanitizedMatch += $Mask
                    }
                    else {
                        $sanitizedMatch += $regexMatch.Value[$i]
                    }
                }

                $Message = $Message.Replace($regexMatch.Value, $sanitizedMatch)
            }
        }
    }

    return $Message
}
