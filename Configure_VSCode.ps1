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
Import-Module -Name ($PSScriptRoot + '\lib\Utils.psm1')


# Functions
# ---------------------------------------------------------------------------------------------
function UninstallExtensions {
    [CmdletBinding()]
    [OutputType([void])]
    param ()

    Write-Output -InputObject ('Uninstalling extensions...')

    # TODO: This.
}

function InstallExtensions {
    [CmdletBinding()]
    [OutputType([void])]
    param ()

    Write-Output -InputObject ("`r`n" + 'Installing extensions...')

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
        StartProcess -FilePath $VSCodeExecFile -ArgumentList @('--install-extension', $Extension, '--force') -Wait -DisplayOutput |
            Select-String -Pattern 'Installing extensions...' -NotMatch  # Refine output
    }
}

function WriteConfig {
    [CmdletBinding()]
    [OutputType([void])]
    param ()

    Write-Output -InputObject ("`r`n" + 'Searching for PHP executable...')

    $PHPExec = FindFile -Path $Env:SystemDrive -FileName 'php.exe' -PathRegex '(php[-_ ]?5\.[0-9])'

    Write-Output -InputObject ("`r`n" + 'Writing config...')

    $VSCodeCfgFile = $Env:AppData + '\Code\User\settings.json'

    $VSCodeCfgObj = [PSCustomObject]@{
        '[json]' = @{
            'editor.detectIndentation' = $false
            'editor.insertSpaces' = $true
            'editor.tabSize' = 2
        }
        '[jsonc]' = @{
            'editor.detectIndentation' = $false
            'editor.insertSpaces' = $true
            'editor.tabSize' = 2
        }
        'editor.suggestSelection' = 'first'
        'html.format.wrapAttributes' = 'force-expand-multiline'
        'importSorter.importStringConfiguration.maximumNumberOfImportExpressionsPerLine.count' = 120
        'importSorter.sortConfiguration.customOrderingRules.rules' = @(
            @{
                'numberOfEmptyLinesAfterGroup' = 1
                'orderLevel' = 40
                'regex' = '^@app'
            },
            @{
                'numberOfEmptyLinesAfterGroup' = 1
                'orderLevel' = 50
                'regex' = '^src'
            },
            @{
                'disableSort' = $true
                'orderLevel' = 5
                'type' = 'importMember'
                'regex' = '^$'
            },
            @{
                'regex' = '^[^.@]'
                'orderLevel' = 10
            },
            @{
                'regex' = '^[@]'
                'orderLevel' = 15
            },
            @{
                'regex' = '^[.]'
                'orderLevel' = 30
            }
        )
        'javascript.preferences.importModuleSpecifier' = 'non-relative'
        'javascript.preferences.quoteStyle' = 'single'
        'javascript.updateImportsOnFileMove.enabled' = 'always'
        'php.validate.executablePath' = $PHPExec
        'powershell.codeFormatting.newLineAfterCloseBrace' = $false
        'powershell.codeFormatting.pipelineIndentationStyle' = 'IncreaseIndentationAfterEveryPipeline'
        'powershell.codeFormatting.useCorrectCasing' = $true
        'terminal.integrated.shell.windows' = $Env:WinDir + '\System32\cmd.exe'
        'todo-tree.customHighlight' = @{
            'TODO' = @{}
            'FIXME' = @{}
        }
        'todo-tree.defaultHighlight' = @{
            'foreground' = 'green'
            'type' = 'text'
        }
        'typescript.preferences.importModuleSpecifier' = 'non-relative'
        'typescript.preferences.quoteStyle' = 'single'
        'typescript.updateImportsOnFileMove.enabled' = 'always'
        'vsintellicode.modify.editor.suggestSelection' = 'automaticallyOverrodeDefaultValue'
        'workbench.colorTheme' = 'Darcula'
        'workbench.startupEditor' = 'none'
    }

    $VSCodeCfgStr = ConvertToJson -InputObject $VSCodeCfgObj

    WriteToFile -FilePath $VSCodeCfgFile -Contents $VSCodeCfgStr
}


# Start point
# ---------------------------------------------------------------------------------------------
try {
    UninstallExtensions

    InstallExtensions

    WriteConfig

    ExitWithCode -Code 0 -Beep -Prompt
} catch {
    ExitWithCode -Code 1 -Beep -Prompt -Error $_
}
