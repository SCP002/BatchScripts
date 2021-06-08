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

    $VSCodeProcesses = Get-Process -Name 'Code' -ErrorAction SilentlyContinue

    if ($VSCodeProcesses) {
        $Message = @(
            'Visual Studio Code is running.',
            'To uninstall extensions correctly it is required to close VSCode.',
            'Please select action:'
        )

        $Choices = @(
            '&Skip uninstalling',
            '&Close Visual Studio Code',
            '&Exit'
        )

        $OptionIndex = PromptForChoice -Message $Message -Choices $Choices

        switch ($OptionIndex) {
            0 { return }
            1 { Stop-Process -Name 'Code' -Force }
            2 { exit 1 }
        }
    }

    RemoveItem -Path ($Env:UserProfile + '\.vscode') -ItemName 'extensions' -Directory
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
        'DavidAnson.vscode-markdownlint',
        'EditorConfig.EditorConfig',
        'Gruntfuggly.todo-tree',
        'k--kato.intellij-idea-keybindings',
        'rokoroku.vscode-theme-darcula',
        'Tyriar.sort-lines',

        # Go
        'golang.Go',

        # PHP
        'bmewburn.vscode-intelephense-client',

        # TypeScript
        'mike-co.import-sorter',
        'ms-vscode.vscode-typescript-tslint-plugin',

        # Web
        'dbaeumer.vscode-eslint',
        'ecmel.vscode-html-css',
        'eg2.vscode-npm-script',
        'michelemelluso.code-beautifier',
        'VisualStudioExptTeam.vscodeintellicode'
    )

    $ExtensionsLen = $Extensions.Count
    $CurrentExtensionNumber = 1

    foreach ($Extension in $Extensions) {
        $Status = '[{0} / {1}] ' -f @($CurrentExtensionNumber, $ExtensionsLen)

        try {
            StartProcess -FilePath $VSCodeExecFile -ArgumentList @('--install-extension', $Extension, '--force') -Wait |
                Select-String -Pattern 'Installing extensions\.\.\.' -NotMatch |  # Refine output
                    ForEach-Object -Process { $Status + $_ }  # Add status to output
        } catch [System.Management.Automation.RemoteException] {
            # Suppress DeprecationWarning
            if ($_.Exception.Message -notlike '*DeprecationWarning*') {
                $_
            }
        }

        $CurrentExtensionNumber += 1
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
        '[go]' = @{
            'editor.rulers' = @(
                120
            )
        }
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
        'files.autoSave' = 'afterDelay'
        'go.formatTool' = 'goimports'
        'go.lintTool' = 'golangci-lint'
        'go.toolsEnvVars' = @{
            'GO111MODULE' = 'on'
        }
        'go.toolsManagement.autoUpdate' = $true
        'go.useLanguageServer' = $true
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
        'terminal.integrated.defaultProfile.windows' = 'Command Prompt'
        'todo-tree.highlights.customHighlight' = @{
            'TODO' = @{}
            'FIXME' = @{}
        }
        'todo-tree.highlights.defaultHighlight' = @{
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
