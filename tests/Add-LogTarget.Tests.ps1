$there = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src"
$sut = "Logger"

# remove already imported Logger module (if any)
Remove-Module -Name Logger -Force -Confirm:$False -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

# import dev version of the module
Import-Module "$there\$sut" -Force

Describe "Add-LogTarget" {
    Context "Name parameter" {
        $values = ((Get-Command -Name "Add-LogTarget" | Select -ExpandProperty Parameters).Name | Select -ExpandProperty Attributes).ValidValues | Sort
        $acceptCount = 12

        It "Exists and are mandatory" {
            Get-Command -Name "Add-LogTarget" | Should -HaveParameter -ParameterName "Name" -Type String -Mandatory
        }

        It "Accepts $acceptCount values" {
            $values.Count | Should BeExactly $acceptCount
        }

        It "Accepts value 'Archeo'" {
            $values | Should Contain 'Archeo'
        }

        It "Accepts value 'AzureLogAnalytics'" {
            $values | Should Contain 'AzureLogAnalytics'
        }

        It "Accepts value 'CMTrace'" {
            $values | Should Contain 'CMTrace'
        }

        It "Accepts value 'Console'" {
            $values | Should Contain 'Console'
        }

        It "Accepts value 'ElasticSearch'" {
            $values | Should Contain 'ElasticSearch'
        }

        It "Accepts value 'Email'" {
            $values | Should Contain 'Email'
        }

        It "Accepts value 'EventLog'" {
            $values | Should Contain 'EventLog'
        }

        It "Accepts value 'File'" {
            $values | Should Contain 'File'
        }

        It "Accepts value 'Seq'" {
            $values | Should Contain 'Seq'
        }

        It "Accepts value 'Slack'" {
            $values | Should Contain 'Slack'
        }

        It "Accepts value 'Teams'" {
            $values | Should Contain 'Teams'
        }

        It "Accepts value 'WebexTeams'" {
            $values | Should Contain 'WebexTeams'
        }
    }

    Context "File target" {
        It "Target added" {
            Add-LogTarget -Name file
            (Get-LogTarget).Count | Should BeExactly 1
        }

        It "Added target is File" {
            (Get-LogTarget).File | Should Not BeNullOrEmpty
        }
    }
}