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


# Imports
# ---------------------------------------------------------------------------------------------
. ($PSScriptRoot + '\Utils.ps1')


# Global variables
# ---------------------------------------------------------------------------------------------
Write-Output -InputObject ('Searching for PHP executable...')

$PHPExec = Get-Childitem –Path ($Env:SystemDrive + '\*') -Include 'php.exe' -Recurse -Force -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty 'FullName' -First 1

$PHPExec = $PHPExec.Replace('\', '\\')

# Assignment moved to global namespace to keep here-string indentation.
# Not using string expansion ("$Var") to avoid possible unwanted references.
# Not using string formatting (-f) because it can not be applied to here-strings.
# Not using ConvertTo-Json commandlet because in PS v5.1 it produces wrong indentation before lists and dicts.
$VSCodeCfg = @'
{
    "editor.suggestSelection": "first",
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
    "php.validate.executablePath": "{PHP_EXEC}",
    "powershell.codeFormatting.newLineAfterCloseBrace": false,
    "powershell.codeFormatting.pipelineIndentationStyle": "IncreaseIndentationAfterEveryPipeline",
    "powershell.codeFormatting.useCorrectCasing": true,
    "terminal.integrated.shell.windows": "{SYS_DRIVE}\\WINDOWS\\System32\\cmd.exe",
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
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "workbench.colorTheme": "Darcula",
    "workbench.startupEditor": "none"
}
'@

$VSCodeCfg = $VSCodeCfg.Replace('{PHP_EXEC}', $PHPExec)
$VSCodeCfg = $VSCodeCfg.Replace('{SYS_DRIVE}', $Env:SystemDrive)


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
        'bmewburn.vscode-intelephense-client',

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
        StartProcess -FilePath $VSCodeExecFile -ArgumentList @('--install-extension', $Extension) -Wait -DisplayOutput |
            Select-String -Pattern 'Installing extensions...' -NotMatch  # Refine output
    }
}

function WriteConfig {
    [CmdletBinding()]
    [OutputType([void])]
    param ()

    Write-Output -InputObject ("`r`n" + 'Writing config...')

    $VSCodeCfgFile = $Env:AppData + '\Code\User\settings.json'

    WriteToFile -FilePath $VSCodeCfgFile -Contents $VSCodeCfg
}


# Start point
# ---------------------------------------------------------------------------------------------
try {
    InstallExtensions

    WriteConfig

    ExitWithCode -Code 0 -Beep -Prompt
} catch {
    ExitWithCode -Code 1 -Beep -Prompt -Error $_
}
