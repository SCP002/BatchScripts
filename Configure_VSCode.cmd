@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Echo SetVariables...

Set VSCode_Exec=%LocalAppData%\Programs\Microsoft VS Code\bin\code.cmd
Set VSCode_Cfg=%AppData%\Code\User\settings.json



:: InstallExtensions
:: ---------------------------------------------------------------------------------------------
:InstallExtensions
Echo.
Echo InstallExtensions...

:: Angular
Call "%VSCode_Exec%" "--install-extension" "Angular.ng-template"

:: General
Call "%VSCode_Exec%" "--install-extension" "christian-kohler.path-intellisense"
Call "%VSCode_Exec%" "--install-extension" "EditorConfig.EditorConfig"
Call "%VSCode_Exec%" "--install-extension" "Gruntfuggly.todo-tree"
Call "%VSCode_Exec%" "--install-extension" "k--kato.intellij-idea-keybindings"
Call "%VSCode_Exec%" "--install-extension" "rokoroku.vscode-theme-darcula"
Call "%VSCode_Exec%" "--install-extension" "Tyriar.sort-lines"

:: PHP
Call "%VSCode_Exec%" "--install-extension" "felixfbecker.php-intellisense"

:: TypeScript
Call "%VSCode_Exec%" "--install-extension" "eg2.tslint"
Call "%VSCode_Exec%" "--install-extension" "mike-co.import-sorter"

:: Web
Call "%VSCode_Exec%" "--install-extension" "dbaeumer.vscode-eslint"
Call "%VSCode_Exec%" "--install-extension" "ecmel.vscode-html-css"
Call "%VSCode_Exec%" "--install-extension" "eg2.vscode-npm-script"
Call "%VSCode_Exec%" "--install-extension" "michelemelluso.code-beautifier"



:: WriteConfig
:: ---------------------------------------------------------------------------------------------
:WriteConfig
Echo.
Echo WriteConfig...

Echo {>                                                                                                 %VSCode_Cfg%
Echo     "html.format.wrapAttributes": "force-expand-multiline",>>                                      %VSCode_Cfg%
Echo     "importSorter.importStringConfiguration.maximumNumberOfImportExpressionsPerLine.count": 120,>> %VSCode_Cfg%
Echo     "importSorter.sortConfiguration.customOrderingRules.rules": [>>                                %VSCode_Cfg%
Echo         {>>                                                                                        %VSCode_Cfg%
Echo             "regex": "^@app",>>                                                                    %VSCode_Cfg%
Echo             "orderLevel": 40,>>                                                                    %VSCode_Cfg%
Echo             "numberOfEmptyLinesAfterGroup": 1,>>                                                   %VSCode_Cfg%
Echo         },>>                                                                                       %VSCode_Cfg%
Echo         {>>                                                                                        %VSCode_Cfg%
Echo             "regex": "^src",>>                                                                     %VSCode_Cfg%
Echo             "orderLevel": 50,>>                                                                    %VSCode_Cfg%
Echo             "numberOfEmptyLinesAfterGroup": 1,>>                                                   %VSCode_Cfg%
Echo         },>>                                                                                       %VSCode_Cfg%
Echo         {>>                                                                                        %VSCode_Cfg%
Echo             "type": "importMember",>>                                                              %VSCode_Cfg%
Echo             "regex": "^$",>>                                                                       %VSCode_Cfg%
Echo             "orderLevel": 5,>>                                                                     %VSCode_Cfg%
Echo             "disableSort": true,>>                                                                 %VSCode_Cfg%
Echo         },>>                                                                                       %VSCode_Cfg%
Echo         {>>                                                                                        %VSCode_Cfg%
Echo             "regex": "^[^.@]",>>                                                                   %VSCode_Cfg%
Echo             "orderLevel": 10,>>                                                                    %VSCode_Cfg%
Echo         },>>                                                                                       %VSCode_Cfg%
Echo         {>>                                                                                        %VSCode_Cfg%
Echo             "regex": "^[@]",>>                                                                     %VSCode_Cfg%
Echo             "orderLevel": 15,>>                                                                    %VSCode_Cfg%
Echo         },>>                                                                                       %VSCode_Cfg%
Echo         {>>                                                                                        %VSCode_Cfg%
Echo             "regex": "^[.]",>>                                                                     %VSCode_Cfg%
Echo             "orderLevel": 30,>>                                                                    %VSCode_Cfg%
Echo         },>>                                                                                       %VSCode_Cfg%
Echo     ],>>                                                                                           %VSCode_Cfg%
Echo     "javascript.preferences.importModuleSpecifier": "non-relative",>>                              %VSCode_Cfg%
Echo     "javascript.preferences.quoteStyle": "single",>>                                               %VSCode_Cfg%
Echo     "javascript.updateImportsOnFileMove.enabled": "always",>>                                      %VSCode_Cfg%
Echo     "terminal.integrated.shell.windows": "C:\\WINDOWS\\System32\\cmd.exe",>>                       %VSCode_Cfg%
Echo     "todo-tree.customHighlight": {>>                                                               %VSCode_Cfg%
Echo         "TODO": {},>>                                                                              %VSCode_Cfg%
Echo         "FIXME": {},>>                                                                             %VSCode_Cfg%
Echo     },>>                                                                                           %VSCode_Cfg%
Echo     "todo-tree.defaultHighlight": {>>                                                              %VSCode_Cfg%
Echo         "foreground": "green",>>                                                                   %VSCode_Cfg%
Echo         "type": "text",>>                                                                          %VSCode_Cfg%
Echo     },>>                                                                                           %VSCode_Cfg%
Echo     "typescript.preferences.importModuleSpecifier": "non-relative",>>                              %VSCode_Cfg%
Echo     "typescript.preferences.quoteStyle": "single",>>                                               %VSCode_Cfg%
Echo     "typescript.updateImportsOnFileMove.enabled": "always",>>                                      %VSCode_Cfg%
Echo     "workbench.colorTheme": "Darcula",>>                                                           %VSCode_Cfg%
Echo     "workbench.startupEditor": "none",>>                                                           %VSCode_Cfg%
Echo }>>                                                                                                %VSCode_Cfg%



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit

PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
