#Requires -Version 5.1

<#
.SYNOPSIS

Collection of utility functions.

.NOTES

Encoding: UTF-8-BOM. Required to correctly recognize UTF-8 in PowerShell.
#>


# Preferences
# ---------------------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'

Set-StrictMode -Version Latest


# Imports
# ---------------------------------------------------------------------------------------------
Add-Type -Path ($PSScriptRoot + '\Newtonsoft.Json.dll')


# Functions
# ---------------------------------------------------------------------------------------------
function PromptForChoice {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        # Caption
        [Parameter()]
        [string]
        $Caption = "`r`n",

        # Message
        [Parameter(Mandatory = $true)]
        [string[]]
        $Message,

        # Choices
        [Parameter(Mandatory = $true)]
        [string[]]
        $Choices,

        # Default choice
        [Parameter()]
        [int]
        $DefaultChoise = 0
    )

    # Build newline-separated string from message array
    $MessageStr = $Message -join "`r`n"

    # Cast choices string array to 'ChoiceDescription' objects array
    $ChoicesObj = [System.Management.Automation.Host.ChoiceDescription[]]$Choices

    # Prompt for choice
    $OptionIndex = $Host.UI.PromptForChoice($Caption, $MessageStr, $ChoicesObj, $DefaultChoise)

    # Return index of selected option
    return $OptionIndex
}

function RemoveItem {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        # Path
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # Item name
        [Parameter(Mandatory = $true)]
        [string]
        $ItemName,

        # Directory
        [Parameter()]
        [switch]
        $Directory,

        # Recurse
        [Parameter()]
        [switch]
        $Recurse,

        # What if
        [Parameter()]
        [switch]
        $WhatIf
    )

    # Build Get-Childitem commandlet arguments
    $GetChildItemArgs = @{
        'Path' = $Path
        'Filter' = $ItemName
        'Force' = $true
    }

    if ($Directory) {
        $GetChildItemArgs.Add('Directory', $true)
    } else {
        $GetChildItemArgs.Add('File', $true)
    }

    if ($Recurse) {
        $GetChildItemArgs.Add('Recurse', $true)
    }

    # Build Remove-Item commandlet arguments
    $RemoveItemArgs = @{
        'Recurse' = $true
        'Force' = $true
    }

    if ($WhatIf) {
        $RemoveItemArgs.Add('WhatIf', $true)
    }

    # Remove items
    Get-Childitem @GetChildItemArgs | Remove-Item @RemoveItemArgs
}

function FindFile {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Path
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # File name
        [Parameter(Mandatory = $true)]
        [string]
        $FileName,

        # Path regex
        [Parameter()]
        [string]
        $PathRegex = '.*'
    )

    # If path is a drive root, add slash to resolve path properly
    if ($Path.EndsWith(':')) {
        $Path += '\'
    }

    # Search
    $Result = Get-Childitem –Path $Path -Filter $FileName -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object -Property 'DirectoryName' -Match $PathRegex -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty 'FullName' -First 1

    # Return full file path
    return $Result
}

function WriteToFile {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        # File path
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath,

        # Contents
        [Parameter(Mandatory = $true)]
        [string[]]
        $Contents
    )

    # Create file
    $Path = Split-Path -Path $FilePath
    $File = Split-Path -Path $FilePath -Leaf
    $FilePath = New-Item -Path $Path -Name $File -ItemType 'File' -Force

    # Write file
    # Using WriteAllLines to enforce UTF-8 encoding (without BOM)
    [System.IO.File]::WriteAllLines($FilePath, $Contents)
}

function ConvertToJson {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Input object
        [Parameter(Mandatory = $true)]
        [PSCustomObject]
        $InputObject,

        # Compress
        [Parameter()]
        [switch]
        $Compress,

        # Depth
        [Parameter()]
        [int]
        $Depth = 4
    )

    # Cast input type to PSCustomObject to have output keys ordered alphabetically
    $InputObject = [PSCustomObject]$InputObject

    # Convert input object to minified JSON string
    $OutputObject = ConvertTo-Json -InputObject $InputObject -Depth $Depth -Compress

    # Convert minified JSON string to readable format
    # Using [Newtonsoft.Json.Linq.JToken]::Parse() to keep proper indentation
    if (-not $Compress) {
        $OutputObject = [Newtonsoft.Json.Linq.JToken]::Parse($OutputObject).ToString()
    }

    # Return output object
    return $OutputObject
}

function StartProcess {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        # File path
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath,

        # Argument list
        [Parameter()]
        [string[]]
        $ArgumentList,

        # Working directory
        [Parameter()]
        [string]
        $WorkingDirectory,

        # Wait
        [Parameter()]
        [switch]
        $Wait
    )

    # Expand FilePath to full form
    $FilePath = Resolve-Path -Path $FilePath

    # Change directory
    if ($WorkingDirectory) {
        Push-Location -Path $WorkingDirectory
    }

    if ($Wait) {  # Output can be captured only if user will to wait for executable to finish
        # Start process, capture output, wait to finish
        & $FilePath $ArgumentList *>&1
    } else {
        # Build Start-Process commandlet arguments
        $StartProcessArgs = @{
            'FilePath' = $FilePath
        }
    
        if ($ArgumentList) {
            $StartProcessArgs.Add('ArgumentList', $ArgumentList)
        }

        # Start process, skip output, continue
        Start-Process @StartProcessArgs
    }

    # Change directory to previous
    if ($WorkingDirectory) {
        Pop-Location
    }
}

function ExitWithCode {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        # Exit code
        [Parameter(Mandatory = $true)]
        [int]
        $Code,

        # Beep before exit
        [Parameter()]
        [switch]
        $Beep,

        # Ask to press <Enter> before exit
        [Parameter()]
        [switch]
        $Prompt,

        # Error record to display
        [Parameter()]
        [System.Management.Automation.ErrorRecord]
        $Error
    )

    if ($Code -eq 0) {
        Write-Host -Object ("`r`n" + 'Job done successfully') -ForegroundColor Green

        if ($Beep) {
            [System.Console]::Beep(500, 500)
            [System.Console]::Beep(700, 500)
        }
    } else {
        Write-Host -Object ("`r`n" + 'Error occured during the job') -ForegroundColor Red

        if ($Error) {
            # Pipe to Out-String required for Write-Host command to print objects correctly
            Write-Host -Object ($Error | Out-String) -ForegroundColor Red
        }

        if ($Beep) {
            [System.Console]::Beep(700, 500)
            [System.Console]::Beep(500, 500)
        }
    }

    if ($Prompt) {
        Read-Host -Prompt ("`r`n" + 'Press <Enter> to exit...')
    }

    exit $Code
}
