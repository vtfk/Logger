<#
.SYNOPSIS
Creates the param used inside the DynamicParam{}-Block

.DESCRIPTION
New-LogDynamicParam creates (or appends) a RuntimeDefinedParameterDictionary
with a parameter whos value is validated through a dynamic validate set.

.PARAMETER Name
displayed parameter name

.PARAMETER Level
Constructs the validate set out of the currently configured logging level names.

.PARAMETER Target
Constructs the validate set out of the currently configured logging targets.

.PARAMETER DynamicParams
Dictionary to be appended. (Useful for multiple dynamic params)

.PARAMETER Mandatory
Controls if parameter is mandatory for call. Defaults to $true

.EXAMPLE
DynamicParam{
    New-LogDynamicParam -Name "Level" -Level -DefaultValue 'Verbose'
}

DynamicParam{
    $dictionary = New-LogDynamicParam -Name "Level" -Level
    New-LogDynamicParam -Name "Target" -Target -DynamicParams $dictionary
}
#>

function New-LogDynamicParam
{
    [OutputType([System.Management.Automation.RuntimeDefinedParameterDictionary])]
    [CmdletBinding(DefaultParameterSetName = "DynamicTarget")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "DynamicLevel")]
        [Parameter(Mandatory = $true, ParameterSetName = "DynamicTarget")]
        [String]$Name,

        [Parameter(Mandatory = $true, ParameterSetName = "DynamicLevel")]
        [switch]$Level,

        [Parameter(Mandatory = $true, ParameterSetName = "DynamicTarget")]
        [switch]$Target,

        [Parameter()]
        [boolean]$Mandatory = $true,

        [Parameter()]
        [Int]$Position = 1,

        [Parameter()]
        [Switch]$ValueFromPipeline,

        [Parameter()]
        [Switch]$ValueFromPipelineByPropertyName,

        [Parameter()]
        [System.Management.Automation.RuntimeDefinedParameterDictionary]$DynamicParams
    )

    if (!$DynamicParams)
    {
        $DynamicParams = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
    }

    $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
    $attribute = [System.Management.Automation.ParameterAttribute]::new()

    $attribute.ParameterSetName = '__AllParameterSets'
    $attribute.Mandatory = $Mandatory
    $attribute.Position = $Position
    $attribute.ValueFromPipeline = $ValueFromPipeline -or $ValueFromPipelineByPropertyName
    $attribute.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName

    $attributeCollection.Add($attribute)


    [String[]] $allowedValues = @()

    switch ($PSCmdlet.ParameterSetName)
    {
        "DynamicTarget"{
            $allowedValues += $Script:Logging.Targets.Keys
        }
        "DynamicLevel" {
            $allowedValues += Get-LevelsName
        }
    }

    $validateSetAttribute = [System.Management.Automation.ValidateSetAttribute]::new($allowedValues)
    $attributeCollection.Add($validateSetAttribute)

    $dynamicParam = [System.Management.Automation.RuntimeDefinedParameter]::new($Name, [string], $attributeCollection)

    $DynamicParams.Add($Name, $dynamicParam)

    return $DynamicParams
}