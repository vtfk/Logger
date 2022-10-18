$there = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src"
$sut = "Logger"
$target = "Email"

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

    Context "Configuration.SMTPServer" {
        It "Exists" {
            $targetContent.Configuration.SMTPServer | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.SMTPServer.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.SMTPServer.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.From" {
        It "Exists" {
            $targetContent.Configuration.From | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.From.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.From.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.To" {
        It "Exists" {
            $targetContent.Configuration.To | Should Not BeNullOrEmpty
        }

        It "Is Required" {
            $targetContent.Configuration.To.Required | Should BeExactly $True
        }

        It "Is of type [string]" {
            $targetContent.Configuration.To.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.Subject" {
        It "Exists" {
            $targetContent.Configuration.Subject | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Subject.Required | Should BeExactly $False
        }

        It "Is of type [string]" {
            $targetContent.Configuration.Subject.Type.Name | Should BeExactly String
        }
    }

    Context "Configuration.BodyAsHtml" {
        It "Exists" {
            $targetContent.Configuration.BodyAsHtml | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.BodyAsHtml.Required | Should BeExactly $False
        }

        It "Is of type [bool]" {
            $targetContent.Configuration.BodyAsHtml.Type.Name | Should BeExactly Boolean
        }

        It "Default is $False" {
            $targetContent.Configuration.BodyAsHtml.Default | Should BeExactly $True
        }
    }

    Context "Configuration.Encoding" {
        It "Exists" {
            $targetContent.Configuration.Encoding | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Encoding.Required | Should BeExactly $False
        }

        It "Is of type [System.Text.Encoding]" {
            $targetContent.Configuration.Encoding.Type.Name | Should BeExactly 'Encoding'
        }

        It "Default is UTF8" {
            $targetContent.Configuration.Encoding.Default.BodyName | Should BeExactly 'utf-8'
        }
    }

    Context "Configuration.Credential" {
        It "Exists" {
            $targetContent.Configuration.Credential | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Credential.Required | Should BeExactly $False
        }

        It "Is of type [pscredential]" {
            $targetContent.Configuration.Credential.Type.Name | Should BeExactly PSCredential
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

    Context "Configuration.Port" {
        It "Exists" {
            $targetContent.Configuration.Port | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.Port.Required | Should BeExactly $False
        }

        It "Is of type [int]" {
            $targetContent.Configuration.Port.Type.Name | Should BeExactly Int32
        }

        It "Default is 25" {
            $targetContent.Configuration.Port.Default | Should BeExactly 25
        }
    }

    Context "Configuration.UseSsl" {
        It "Exists" {
            $targetContent.Configuration.UseSsl | Should Not BeNullOrEmpty
        }

        It "Is NOT Required" {
            $targetContent.Configuration.UseSsl.Required | Should BeExactly $False
        }

        It "Is of type [bool]" {
            $targetContent.Configuration.UseSsl.Type.Name | Should BeExactly Boolean
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
}