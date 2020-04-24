@{
    Name = 'Archeo'
    Configuration = @{
        ApiKey          = @{Required = $true;  Type = [string]}
        TransactionId   = @{Required = $true;  Type = [string]}
        TransactionType = @{Required = $true;  Type = [string]}
        TransactionTag  = @{Required = $true;  Type = [string]}
    }

    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        if ($Log.Verbose)
        {
            $VerbosePreference = "Continue"
        }

        Function Add-BodyContent
        {
            param(
                [Parameter(Mandatory = $True)]
                [string]$FilePath
            )

            # get fileName and fileContent
            $fileName = [System.IO.Path]::GetFileName($FilePath)
            $fileContent = Get-Content -Path $FilePath -Raw -Encoding UTF8
            $fileContentAsBytes = [System.Text.Encoding]::Unicode.GetBytes($fileContent)
            $fileContentAsEncodedText = [Convert]::ToBase64String($fileContentAsBytes)

            $body[0].Add('fileName', $fileName)
            $body[0].Add('bodyContent', $fileContentAsEncodedText)
        }

        #region Parameter validation presets

        $transactionTagCharsNotAllowed = "æ|ø|å|§|¤|£|\\|¨|'"
        $transactionTagMaxLength = 230
        $descriptionMaxLength = 128

        #endregion

        #region Validate parameters

        # TransactionId
        if ([string]::IsNullOrEmpty($Configuration.TransactionId))
        {
            throw "TransactionId is not valid"
        }

        # TransactionType
        if ([string]::IsNullOrEmpty($Configuration.TransactionType))
        {
            throw "TransactionType is not valid"
        }

        # TransactionTag
        if ([string]::IsNullOrEmpty($Configuration.TransactionTag))
        {
            throw "TransactionTag is not valid"
        }
        if ($Configuration.TransactionTag -match $transactionTagCharsNotAllowed)
        {
            throw "TransactionTag '$($Configuration.TransactionTag)' not valid. Characters not allowed are: `"$($transactionTagCharsNotAllowed.Split("|") -join '","')`""
        }
        if ($Configuration.TransactionTag.Length -lt 1 -or $Configuration.TransactionTag.Length -gt $transactionTagMaxLength)
        {
            throw "TransactionTag '$($Configuration.TransactionTag)' not valid. Too few or too many characters. Current length is $($Configuration.TransactionTag.Length). Max (recommended) length is $transactionTagMaxLength"
        }

        # MessageType
        if ([string]::IsNullOrEmpty($Log.Body.MessageType))
        {
            throw "MessageType not provided in Body"
        }

        # Description ($Log.Message)
        if ([string]::IsNullOrEmpty($Log.Message))
        {
            throw "Message not provided"
        }
        if ($Log.Message.Length -lt 1 -or $Log.Message.Length -gt $descriptionMaxLength)
        {
            throw "Message '$($Log.Message)' not valid. Too few or too many characters. Current length is $($Log.Message.Length). Max length is $descriptionMaxLength"
        }

        # Status
        if ([string]::IsNullOrEmpty($Log.Body.Status))
        {
            throw "Status not provided in Body"
        }

        # FilePath
        if ($Log.Body.FilePath -and -not (Test-Path -Path $Log.Body.FilePath))
        {
            throw "FilePath '$($Log.Body.FilePath)' not valid. FilePath doesn't exist or isn't reachable."
        }

        #endregion

        # uri to Archeo
        $uri = "https://api.archeo.no/api/v1.1/log"

        # header
        $headers = @{
            'apikey' = $Configuration.ApiKey
            'Cache-Control' = 'no-cache'
            'Content-Type' = 'application/json'
        }

        # timestamp for post
        $processed = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffzzz'

        # create body hash
        $body = @(
            @{
                transactionId = $Configuration.TransactionId
                transactionType = $Configuration.TransactionType
                transactionTag = $Configuration.TransactionTag
                messageType = $Log.Body.MessageType
                processed = $processed
                description = $Log.Message
                status = $Log.Body.Status
            }
        )

        # add sender to hash
        if ($Log.Body.Sender)
        {
            $body[0].Add('sender', $Log.Body.Sender)
        }

        # add receiver to hash
        if ($Log.Body.Receiver)
        {
            $body[0].Add('receiver', $Log.Body.Receiver)
        }

        # add metadata to hash
        if ($Log.Body.MetaData)
        {
            $body[0].Add('metadata', $Log.Body.MetaData)
        }

        # add fileName and bodyContent to hash
        if ($Log.Body.FilePath)
        {
            # add fileName and bodyContent
            Add-BodyContent -FilePath $Log.Body.FilePath
        }
        # add StackTrace from Exception as fileName and bodyContent to hash
        elseif ($Log.Exception)
        {
            # create a temp file with name errormessage_TransactionId.log with value from Exception
            $filePath = "$env:TEMP\errormessage_$($Configuration.TransactionId).log"
            $content = "$($Log.Exception)`n$($Log.Exception.Exception.ErrorRecord.InvocationInfo.PositionMessage)`n$($Log.Exception.Exception.StackTrace)".Replace("`n", "`r`n")
            [System.IO.File]::WriteAllText($filePath, $content, [System.Text.Encoding]::UTF8)

            # add fileName and bodyContent
            Add-BodyContent -FilePath $filePath
        }

        # convert body to json
        $bodyJson = $body | ConvertTo-Json
        if ($bodyJson.Count -eq 1)
        {
            $bodyJson = "[$bodyJson]"
        }

        # post request
        Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $bodyJson -ContentType 'application/json'
    }
}