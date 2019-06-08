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


# Functions
# ---------------------------------------------------------------------------------------------
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
    $File = Split-Path -Leaf -Path $FilePath
    $FilePath = New-Item -Force -ItemType 'File' -Path $Path -Name $File

    # Write file
    # Using WriteAllLines to enforce UTF-8 encoding (without BOM)
    [System.IO.File]::WriteAllLines($FilePath, $Contents)
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
            & $FilePath $ArgumentList *>&1 | Tee-Object -Variable Out | Out-Default
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
        Write-Host -ForegroundColor Green -Object ("`r`n" + 'Job done successfully')

        if ($Beep) {
            [System.Console]::Beep(500, 500)
            [System.Console]::Beep(700, 500)
        }
    } else {
        Write-Host -ForegroundColor Red -Object ("`r`n" + 'Error occured during the job')

        if ($Error) {
            # Pipe to Out-String required for Write-Host command to print objects correctly
            Write-Host -ForegroundColor Red -Object ($Error | Out-String)
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
