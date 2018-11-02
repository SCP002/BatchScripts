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

:: Python
Call "%VSCode_Path%\code.cmd" "--install-extension" "ms-python.python"
Call "%VSCode_Path%\code.cmd" "--install-extension" "VisualStudioExptTeam.vscodeintellicode"

:: TypeScript
Call "%VSCode_Path%\code.cmd" "--install-extension" "eg2.tslint"
Call "%VSCode_Path%\code.cmd" "--install-extension" "mike-co.import-sorter"

:: Web
Call "%VSCode_Path%\code.cmd" "--install-extension" "dbaeumer.vscode-eslint"
Call "%VSCode_Path%\code.cmd" "--install-extension" "ecmel.vscode-html-css"
Call "%VSCode_Path%\code.cmd" "--install-extension" "eg2.vscode-npm-script"
Call "%VSCode_Path%\code.cmd" "--install-extension" "michelemelluso.code-beautifier"



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit

PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
