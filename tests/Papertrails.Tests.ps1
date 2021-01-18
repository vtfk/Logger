$there = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src"
$sut = "Logger"
$target = "Papertrails"

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

        It "Is Required" {
            $targetContent.Configuration.Port.Required | Should BeExactly $True
        }

        It "Is of type [Int32]" {
            $targetContent.Configuration.Port.Type.Name | Should BeExactly Int32
        }
    }

    Context "Configuration.HostName" {
        It "Exists" {
            $targetContent.Configuration.HostName | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.HostName.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.HostName.Type.Name | Should BeExactly String
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
}