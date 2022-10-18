$there = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src"
$sut = "Logger"
$target = "EventLog"

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

    Context "Configuration.LogName" {
        It "Exists" {
            $targetContent.Configuration.LogName | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.LogName.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.LogName.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.Source" {
        It "Exists" {
            $targetContent.Configuration.Source | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.Source.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.Source.Type.Name | Should BeExactly String
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
}