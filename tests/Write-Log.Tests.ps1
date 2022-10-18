$there = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src"
$sut = "Logger"

# remove already imported Logger module (if any)
Remove-Module -Name Logger -Force -Confirm:$False -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

# import dev version of the module
Import-Module "$there\$sut" -Force

Describe "Write-Log" {
    Context "Message parameter" {
        $attributes = ((Get-Command -Name "Write-Log" | Select -ExpandProperty Parameters).Message | Select -ExpandProperty Attributes)

        It "Exists" {
            $attributes | Should Not BeNullOrEmpty
        }

        It "Is mandatory" {
            $attributes.Mandatory | Should BeExactly $True
        }

        It "Has position 1" {
            $attributes.Position | Should BeExactly 1
        }

        It "Accepts 'ValueFromPipeline'" {
            $attributes.ValueFromPipeline | Should BeExactly $True
        }
    }

    Context "Level parameter" {
        $attributes = ((Get-Command -Name "Write-Log" | Select -ExpandProperty Parameters).Level | Select -ExpandProperty Attributes)
        $values = $attributes.ValidValues | Sort
        $acceptCount = 6

        It "Exists" {
            $attributes | Should Not BeNullOrEmpty
        }

        It "Is NOT mandatory" {
            $attributes.Mandatory | Should BeExactly $False
        }

        It "Has position 2" {
            $attributes.Position | Should BeExactly 2
        }

        It "Accepts $acceptCount values" {
            $values.Count | Should BeExactly $acceptCount
        }

        It "Accepts value 'DEBUG'" {
            $values | Should Contain 'DEBUG'
        }

        It "Accepts value 'ERROR'" {
            $values | Should Contain 'ERROR'
        }

        It "Accepts value 'INFO'" {
            $values | Should Contain 'INFO'
        }

        It "Accepts value 'NOTSET'" {
            $values | Should Contain 'NOTSET'
        }

        It "Accepts value 'SUCCESS'" {
            $values | Should Contain 'SUCCESS'
        }

        It "Accepts value 'WARNING'" {
            $values | Should Contain 'WARNING'
        }
    }

    Context "Arguments parameter" {
        $attributes = ((Get-Command -Name "Write-Log" | Select -ExpandProperty Parameters).Arguments | Select -ExpandProperty Attributes)

        It "Exists" {
            $attributes | Should Not BeNullOrEmpty
        }

        It "Is NOT mandatory" {
            $attributes.Mandatory | Should BeExactly $False
        }
    }

    Context "Body parameter" {
        $attributes = ((Get-Command -Name "Write-Log" | Select -ExpandProperty Parameters).Body | Select -ExpandProperty Attributes)

        It "Exists" {
            $attributes | Should Not BeNullOrEmpty
        }

        It "Is NOT mandatory" {
            $attributes.Mandatory | Should BeExactly $False
        }
    }

    Context "Exception parameter" {
        $attributes = ((Get-Command -Name "Write-Log" | Select -ExpandProperty Parameters).Exception | Select -ExpandProperty Attributes)

        It "Exists" {
            $attributes | Should Not BeNullOrEmpty
        }

        It "Is NOT mandatory" {
            $attributes.Mandatory | Should BeExactly $False
        }
    }
}