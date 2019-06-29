#Requires -Version 5.1

<#
.SYNOPSIS

Starts PHP web server.

.NOTES

Encoding: UTF-8-BOM. Required to correctly recognize UTF-8 in PowerShell.
#>


# Preferences
# ---------------------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'

Set-StrictMode -Version Latest


# Imports
# ---------------------------------------------------------------------------------------------
Import-Module -Name ($PSScriptRoot + '\lib\Utils.psm1')


# Functions
# ---------------------------------------------------------------------------------------------
function StartServer {
    [CmdletBinding()]
    [OutputType([void])]
    param ()

    # Prompt for settings
    $ServePath = Read-Host -Prompt ('Enter path to serve')
    $ServePath = Resolve-Path -Path $ServePath

    ("`r`n" + 'Press <Enter> to set default value')
    $ServeHost = Read-Host -Prompt ('Enter host address')
    [int]$ServePort = Read-Host -Prompt ('Enter port')

    # Set default values
    if (-not $ServeHost) {
        $ServeHost = '127.0.0.1'
    }

    if (-not $ServePort) {
        $ServePort = 8000
    }

    #Search for PHP executable
    ("`r`n" + 'Searching for PHP executable...')
    $PHPExec = FindFile -Path $Env:SystemDrive -FileName 'php.exe' -PathRegex '(php[-_ ]?5\.[0-9])'

    if ($PHPExec) {
        ('PHP executable found: ' + $PHPExec)
    } else {
        throw 'PHP executable not found'
    }

    # Start server
    ("`r`n" + 'Starting server...')
    $Socket = '{0}:{1}' -f @($ServeHost, $ServePort)
    StartProcess -FilePath $PHPExec -ArgumentList @('-S', $Socket, '-t', $ServePath) -WorkingDirectory $ServePath -Wait
}


# Start point
# ---------------------------------------------------------------------------------------------
try {
    StartServer

    ExitWithCode -Code 0 -Beep -Prompt
} catch {
    ExitWithCode -Code 1 -Beep -Prompt -Error $_
}
