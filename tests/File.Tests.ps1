$there = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src"
$logFile = ($MyInvocation.MyCommand.Path).Replace($env:SCRIPT_DIR, $env:LOG_DIR).Replace(".ps1", ".log")
$sut = "Logger"
$target = "File"

# remove already imported Logger module (if any)
Remove-Module -Name Logger -Force -Confirm:$False -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

# import dev version of the module
Import-Module "$there\$sut" -Force

# import content from target file
$targetContent = . "$there\targets\$target.ps1"

Describe "Target $target" {
    It "Exists" {
        $targetContent | Should Not BeNullOrEmpty
    }

    It "Has name '$target'" {
        $targetContent.Name | Should BeExactly $target
    }

    Context "Configuration.Path" {
        It "Exists" {
            $targetContent.Configuration.Path | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Path.Required | Should BeExactly $False
        }

        It "Is of type [string]" {
            $targetContent.Configuration.Path.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.Append" {
        It "Exists" {
            $targetContent.Configuration.Append | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Append.Required | Should BeExactly $False
        }

        It "Is of type [bool]" {
            $targetContent.Configuration.Append.Type.Name | Should BeExactly Boolean
        }

        It "Default is $True" {
            $targetContent.Configuration.Append.Default | Should BeExactly $True
        }
    }

    Context "Configuration.Encoding" {
        It "Exists" {
            $targetContent.Configuration.Encoding | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Encoding.Required | Should BeExactly $False
        }

        It "Is of type [string]" {
            $targetContent.Configuration.Encoding.Type.Name | Should BeExactly String
        }

        It "Default is 'utf8'" {
            $targetContent.Configuration.Encoding.Default | Should BeExactly 'utf8'
        }
    }

    Context "Configuration.Level" {
        It "Exists" {
            $targetContent.Configuration.Level | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Level.Required | Should BeExactly $False
        }

        It "Is of type [string]" {
            $targetContent.Configuration.Level.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.Format" {
        It "Exists" {
            $targetContent.Configuration.Format | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Format.Required | Should BeExactly $False
        }

        It "Is of type [string]" {
            $targetContent.Configuration.Format.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.Sanitize" {
        It "Exists" {
            $targetContent.Configuration.Sanitize | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Sanitize.Required | Should BeExactly $False
        }

        It "Is of type [bool]" {
            $targetContent.Configuration.Sanitize.Type.Name | Should BeExactly Boolean
        }

        It "Default is $False" {
            $targetContent.Configuration.Sanitize.Default | Should BeExactly $False
        }
    }

    Context "Configuration.SanitizeMask" {
        It "Exists" {
            $targetContent.Configuration.SanitizeMask | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.SanitizeMask.Required | Should BeExactly $False
        }

        It "Is of type [bool]" {
            $targetContent.Configuration.SanitizeMask.Type.Name | Should BeExactly Char
        }

        It "Default is '*'" {
            $targetContent.Configuration.SanitizeMask.Default | Should BeExactly '*'
        }
    }

    Context "Configuration.RolloverType" {
        It "Exists" {
            $targetContent.Configuration.RolloverType | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.RolloverType.Required | Should BeExactly $False
        }

        It "Is of type [bool]" {
            $targetContent.Configuration.RolloverType.Type.Name | Should BeExactly String
        }
    }

    Context "Output syntax is correct" {
        Add-LogTarget -Name $target
        Write-Log -Message "First" -Level INFO
        Write-Log -Message "Second" -Level WARNING
        Write-Log -Message "Third" -Level ERROR
        $content = Get-Content -Path $logFile

        It "INFO -eq 1" {
            $content[0] | Should Match "\[$(Get-Date -Format 'dd.MM.yyyy') .+\] \[INFO\] - .+"
        }

        It "WARNING -eq 2" {
            $content[1] | Should Match "\[$(Get-Date -Format 'dd.MM.yyyy') .+\] \[WARNING\] - .+"
        }

        It "ERROR -eq 3" {
            $content[2] | Should Match "\[$(Get-Date -Format 'dd.MM.yyyy') .+\] \[ERROR\] - .+"
        }

        Remove-Item -Path $logFile -Force -Confirm:$False
    }
}