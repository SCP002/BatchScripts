@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Echo SetVariables...

Set VSCode_Path=%LocalAppData%\Programs\Microsoft VS Code\bin
Set VSCode_Config_Path=%AppData%\Code\User\settings.json



:: InstallExtensions
:: ---------------------------------------------------------------------------------------------
:InstallExtensions
Echo.
Echo InstallExtensions...

:: Angular
Call "%VSCode_Path%\code.cmd" "--install-extension" "Angular.ng-template"

:: General
Call "%VSCode_Path%\code.cmd" "--install-extension" "christian-kohler.path-intellisense"
Call "%VSCode_Path%\code.cmd" "--install-extension" "EditorConfig.EditorConfig"
Call "%VSCode_Path%\code.cmd" "--install-extension" "Gruntfuggly.todo-tree"
Call "%VSCode_Path%\code.cmd" "--install-extension" "k--kato.intellij-idea-keybindings"
Call "%VSCode_Path%\code.cmd" "--install-extension" "rokoroku.vscode-theme-darcula"
Call "%VSCode_Path%\code.cmd" "--install-extension" "Tyriar.sort-lines"

:: PHP
Call "%VSCode_Path%\code.cmd" "--install-extension" "felixfbecker.php-intellisense"

:: TypeScript
Call "%VSCode_Path%\code.cmd" "--install-extension" "eg2.tslint"
Call "%VSCode_Path%\code.cmd" "--install-extension" "mike-co.import-sorter"

:: Web
Call "%VSCode_Path%\code.cmd" "--install-extension" "dbaeumer.vscode-eslint"
Call "%VSCode_Path%\code.cmd" "--install-extension" "ecmel.vscode-html-css"
Call "%VSCode_Path%\code.cmd" "--install-extension" "eg2.vscode-npm-script"
Call "%VSCode_Path%\code.cmd" "--install-extension" "michelemelluso.code-beautifier"



:: WriteConfig
:: ---------------------------------------------------------------------------------------------
:WriteConfig
Echo.
Echo WriteConfig...

Echo {>                                                                                                 %VSCode_Config_Path%
Echo     "html.format.wrapAttributes": "force-expand-multiline",>>                                      %VSCode_Config_Path%
Echo     "importSorter.importStringConfiguration.maximumNumberOfImportExpressionsPerLine.count": 120,>> %VSCode_Config_Path%
Echo     "importSorter.sortConfiguration.customOrderingRules.rules": [>>                                %VSCode_Config_Path%
Echo         {>>                                                                                        %VSCode_Config_Path%
Echo             "regex": "^@app",>>                                                                    %VSCode_Config_Path%
Echo             "orderLevel": 40,>>                                                                    %VSCode_Config_Path%
Echo             "numberOfEmptyLinesAfterGroup": ^1>>                                                   %VSCode_Config_Path%
Echo         },>>                                                                                       %VSCode_Config_Path%
Echo         {>>                                                                                        %VSCode_Config_Path%
Echo             "regex": "^src",>>                                                                     %VSCode_Config_Path%
Echo             "orderLevel": 50,>>                                                                    %VSCode_Config_Path%
Echo             "numberOfEmptyLinesAfterGroup": ^1>>                                                   %VSCode_Config_Path%
Echo         },>>                                                                                       %VSCode_Config_Path%
Echo         {>>                                                                                        %VSCode_Config_Path%
Echo             "type": "importMember",>>                                                              %VSCode_Config_Path%
Echo             "regex": "^$",>>                                                                       %VSCode_Config_Path%
Echo             "orderLevel": 5,>>                                                                     %VSCode_Config_Path%
Echo             "disableSort": true>>                                                                  %VSCode_Config_Path%
Echo         },>>                                                                                       %VSCode_Config_Path%
Echo         {>>                                                                                        %VSCode_Config_Path%
Echo             "regex": "^[^.@]",>>                                                                   %VSCode_Config_Path%
Echo             "orderLevel": 10>>                                                                     %VSCode_Config_Path%
Echo         },>>                                                                                       %VSCode_Config_Path%
Echo         {>>                                                                                        %VSCode_Config_Path%
Echo             "regex": "^[@]",>>                                                                     %VSCode_Config_Path%
Echo             "orderLevel": 15>>                                                                     %VSCode_Config_Path%
Echo         },>>                                                                                       %VSCode_Config_Path%
Echo         {>>                                                                                        %VSCode_Config_Path%
Echo             "regex": "^[.]",>>                                                                     %VSCode_Config_Path%
Echo             "orderLevel": 30>>                                                                     %VSCode_Config_Path%
Echo         },>>                                                                                       %VSCode_Config_Path%
Echo     ],>>                                                                                           %VSCode_Config_Path%
Echo     "javascript.preferences.importModuleSpecifier": "non-relative",>>                              %VSCode_Config_Path%
Echo     "javascript.preferences.quoteStyle": "single",>>                                               %VSCode_Config_Path%
Echo     "javascript.updateImportsOnFileMove.enabled": "always",>>                                      %VSCode_Config_Path%
Echo     "terminal.integrated.shell.windows": "C:\\WINDOWS\\System32\\cmd.exe",>>                       %VSCode_Config_Path%
Echo     "todo-tree.customHighlight": {>>                                                               %VSCode_Config_Path%
Echo         "TODO": {},>>                                                                              %VSCode_Config_Path%
Echo         "FIXME": {}>>                                                                              %VSCode_Config_Path%
Echo     },>>                                                                                           %VSCode_Config_Path%
Echo     "todo-tree.defaultHighlight": {>>                                                              %VSCode_Config_Path%
Echo         "foreground": "green",>>                                                                   %VSCode_Config_Path%
Echo         "type": "text">>                                                                           %VSCode_Config_Path%
Echo     },>>                                                                                           %VSCode_Config_Path%
Echo     "typescript.preferences.importModuleSpecifier": "non-relative",>>                              %VSCode_Config_Path%
Echo     "typescript.preferences.quoteStyle": "single",>>                                               %VSCode_Config_Path%
Echo     "typescript.updateImportsOnFileMove.enabled": "always",>>                                      %VSCode_Config_Path%
Echo     "workbench.colorTheme": "Darcula",>>                                                           %VSCode_Config_Path%
Echo     "workbench.startupEditor": "none",>>                                                           %VSCode_Config_Path%
Echo }>>                                                                                                %VSCode_Config_Path%



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit

PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
