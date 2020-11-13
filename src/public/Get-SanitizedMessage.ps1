Function Get-SanitizedMessage
{
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
            name = "bank account numbers"
            pattern = "(\d{4}) (\d{2}) (\d{5})"
            replacement = "$((1..4 | % { "$Mask" }) -join '') $((1..2 | % { $Mask }) -join '') $((1..2 | % { $Mask }) -join '')ddd"
        },
        @{
            name = "credit card numbers (no spaces)"
            pattern = "\d{16}"
            replacement = "$((1..12 | % { $Mask }) -join '')dddd"
        },
        @{
            name = "credit card numbers (with spaces)"
            pattern = "(\d{4}) (\d{4}) (\d{4}) (\d{4})"
            replacement = "$((1..4 | % { $Mask }) -join '') $((1..4 | % { $Mask }) -join '') $((1..4 | % { $Mask }) -join '') dddd"
        },
        @{
            name = "social security number"
            pattern = "\d{11}"
            replacement = "dddddd$((1..5 | % { $Mask }) -join '')"
        }
    )

    foreach ($regexPattern in $regexPatterns) {
        if (($regexPattern.name -like "bank account*" -and !$BankAccountNumber) -or
            ($regexPattern.name -like "credit card*" -and !$CreditCardNumber) -or
            ($regexPattern.name -like "social*" -and !$SocialSecurityNumber)) {
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
                            #Write-Host "Match is inside another string. Skipping" -ForegroundColor Yellow
                            continue matchesLoop;
                        }

                        if ($nextIndex -le $Message.Length) {
                            $nextIndexChar = $Message[$nextIndex]
                            if ($nextIndexChar -match "[a-zæøå]|[A-ZÆØÅ]|[0-9]|['`"]") {
                                #Write-Host "Match is inside another string. Skipping" -ForegroundColor Yellow
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
