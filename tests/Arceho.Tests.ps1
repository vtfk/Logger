$there = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src"
$sut = "Logger"
$target = "Archeo"

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

    Context "Configuration.ApiKey" {
        It "Exists" {
            $targetContent.Configuration.ApiKey | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.ApiKey.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.ApiKey.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.TransactionId" {
        It "Exists" {
            $targetContent.Configuration.TransactionId | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.TransactionId.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.TransactionId.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.TransactionTag" {
        It "Exists" {
            $targetContent.Configuration.TransactionTag | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.TransactionTag.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.TransactionTag.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.TransactionType" {
        It "Exists" {
            $targetContent.Configuration.TransactionType | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.TransactionType.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.TransactionType.Type.Name | Should BeExactly String
        }
    }
}