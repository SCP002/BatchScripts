﻿#Requires -Version 5.1

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
function FindFile {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Root
        [Parameter(Mandatory = $true)]
        [string]
        $Root,

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
    if ($Root.EndsWith(':')) {
        $Root += '\'
    }

    $Result = Get-Childitem –Path $Root -Filter $FileName -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object -Property 'DirectoryName' -Match $PathRegex -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty 'FullName' -First 1

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
    [OutputType([PSCustomObject])]
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
        $Wait,

        # Display output
        [Parameter()]
        [switch]
        $DisplayOutput
    )

    # Prepare variables
    $Result = [PSCustomObject]@{
        Success = $false
        ExitCode = -1
        Out = ''
    }

    # Expand FilePath to full form
    $FilePath = Resolve-Path -Path $FilePath

    # Change directory
    if ($WorkingDirectory) {
        Push-Location -Path $WorkingDirectory
    }

    # Start process
    if ($Wait) {  # Output can be captured only if user will to wait for executable to finish
        if ($DisplayOutput) {
            & $FilePath $ArgumentList *>&1 | Tee-Object -Variable Out
        } else {
            & $FilePath $ArgumentList *>&1 | Tee-Object -Variable Out | Out-Null
        }
    } else {
        Start-Process -FilePath $FilePath -ArgumentList $ArgumentList
    }

    # Prepare result object
    $Result.Success = $?
    $Result.ExitCode = $LASTEXITCODE
    $Result.Out = ($Out | Out-String)

    # Change directory to previous
    if ($WorkingDirectory) {
        Pop-Location
    }

    # Return result object
    return $Result
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
        Read-Host -Prompt ('Press <Enter> to exit...')
    }

    exit $Code
}
