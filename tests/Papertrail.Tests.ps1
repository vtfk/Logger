$there = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src"
$sut = "Logger"
$target = "Papertrail"

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

    Context "Configuration.Server" {
        It "Exists" {
            $targetContent.Configuration.Server | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.Server.Required | Should BeExactly $False
        }

        It "Is of type [string]" {
            $targetContent.Configuration.Server.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.Port" {
        It "Exists" {
            $targetContent.Configuration.Port | Should Not BeNullOrEmpty
        }

        It "Is of type [Int32]" {
            $targetContent.Configuration.Port.Type.Name | Should BeExactly Int32
        }
    }

    Context "Configuration.HostName" {
        It "Exists" {
            $targetContent.Configuration.HostName | Should Not BeNullOrEmpty
        }

        It "Is of type [string]" {
            $targetContent.Configuration.HostName.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.Token" {
        It "Exists" {
            $targetContent.Configuration.Token | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.Token.Required | Should BeExactly $False
        }

        It "Is of type [string]" {
            $targetContent.Configuration.Token.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.Facility" {
        It "Exists" {
            $targetContent.Configuration.Facility | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.Facility.Required | Should BeExactly $False
        }

        It "Is of type [string]" {
            $targetContent.Configuration.Facility.Type.Name | Should BeExactly String
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