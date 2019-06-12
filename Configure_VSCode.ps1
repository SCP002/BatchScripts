#Requires -Version 5.1

<#
.SYNOPSIS

Installs Visual Studio Code extensions and writes config.

.NOTES

Encoding: UTF-8-BOM. Required to correctly recognize UTF-8 in PowerShell.
#>


# Preferences
# ---------------------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'

Set-StrictMode -Version Latest


# Global variables
# ---------------------------------------------------------------------------------------------
$VSCodeCfg = @'
{
    "html.format.wrapAttributes": "force-expand-multiline",
    "importSorter.importStringConfiguration.maximumNumberOfImportExpressionsPerLine.count": 120,
    "importSorter.sortConfiguration.customOrderingRules.rules": [
        {
            "regex": "^@app",
            "orderLevel": 40,
            "numberOfEmptyLinesAfterGroup": 1
        },
        {
            "regex": "^src",
            "orderLevel": 50,
            "numberOfEmptyLinesAfterGroup": 1
        },
        {
            "type": "importMember",
            "regex": "^$",
            "orderLevel": 5,
            "disableSort": true
        },
        {
            "regex": "^[^.@]",
            "orderLevel": 10
        },
        {
            "regex": "^[@]",
            "orderLevel": 15
        },
        {
            "regex": "^[.]",
            "orderLevel": 30
        }
    ],
    "javascript.preferences.importModuleSpecifier": "non-relative",
    "javascript.preferences.quoteStyle": "single",
    "javascript.updateImportsOnFileMove.enabled": "always",
    "powershell.codeFormatting.newLineAfterCloseBrace": false,
    "powershell.codeFormatting.pipelineIndentationStyle": "IncreaseIndentationAfterEveryPipeline",
    "powershell.codeFormatting.useCorrectCasing": true,
    "terminal.integrated.shell.windows": "C:\\WINDOWS\\System32\\cmd.exe",
    "todo-tree.customHighlight": {
        "TODO": {},
        "FIXME": {}
    },
    "todo-tree.defaultHighlight": {
        "foreground": "green",
        "type": "text"
    },
    "typescript.preferences.importModuleSpecifier": "non-relative",
    "typescript.preferences.quoteStyle": "single",
    "typescript.updateImportsOnFileMove.enabled": "always",
    "workbench.colorTheme": "Darcula",
    "workbench.startupEditor": "none"
}
'@


# Functions
# ---------------------------------------------------------------------------------------------
function InstallExtensions {
    [CmdletBinding()]
    [OutputType([void])]
    param ()

    Write-Output -InputObject ('Installing extensions...')

    $VSCodeExecFile = $Env:LocalAppData + '\Programs\Microsoft VS Code\bin\code.cmd'

    $Extensions = @(
        # Angular
        'Angular.ng-template',

        # General
        'christian-kohler.path-intellisense',
        'EditorConfig.EditorConfig',
        'formulahendry.code-runner',
        'Gruntfuggly.todo-tree',
        'k--kato.intellij-idea-keybindings',
        'rokoroku.vscode-theme-darcula',
        'Tyriar.sort-lines',

        # PHP
        'felixfbecker.php-intellisense',

        # PowerShell
        'ms-vscode.powershell',

        # TypeScript
        'mike-co.import-sorter',
        'ms-vscode.vscode-typescript-tslint-plugin',

        # Web
        'dbaeumer.vscode-eslint',
        'ecmel.vscode-html-css',
        'eg2.vscode-npm-script',
        'michelemelluso.code-beautifier',
        'visualstudioexptteam.vscodeintellicode'
    )

    foreach ($Extension in $Extensions) {
        Start-Process -FilePath $VSCodeExecFile -ArgumentList @('--install-extension', $Extension) -NoNewWindow -Wait
    }
}

function WriteConfig {
    [CmdletBinding()]
    [OutputType([void])]
    param ()

    Write-Output -InputObject ("`r`n" + 'Writing config...')

    $VSCodeCfgFile = $Env:AppData + '\Code\User\settings.json'

    # Using WriteAllLines to enforce UTF-8 encoding (without BOM)
    [System.IO.File]::WriteAllLines($VSCodeCfgFile, $VSCodeCfg)
}

function ExitWithCode {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        # Exit code.
        [Parameter(Mandatory = $true)]
        [int]
        $Code,

        # Beep before exit or not.
        [Parameter()]
        [bool]
        $Beep = $false,

        # Ask to press <Enter> before exit or not.
        [Parameter()]
        [bool]
        $Prompt = $false,

        # Error record to display.
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


# Start point
# ---------------------------------------------------------------------------------------------
try {
    InstallExtensions

    WriteConfig

    ExitWithCode -Code 0 -Beep $true -Prompt $true
} catch {
    ExitWithCode -Code 1 -Beep $true -Prompt $true -Error $_
}
