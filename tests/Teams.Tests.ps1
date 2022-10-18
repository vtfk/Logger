$there = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src"
$sut = "Logger"
$target = "Teams"

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

    Context "Configuration.WebHook" {
        It "Exists" {
            $targetContent.Configuration.WebHook | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.WebHook.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.WebHook.Type.Name | Should BeExactly String
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

    Context "Configuration.ColorMapping" {
        It "Exists" {
            $targetContent.Configuration.ColorMapping | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.ColorMapping.Required | Should BeExactly $False
        }

        It "Is of type [hashtable]" {
            $targetContent.Configuration.ColorMapping.Type.Name | Should BeExactly Hashtable
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
            $targetContent.Configuration.SanitizeMask.Default | Should BeExactly '#'
        }
    }
}