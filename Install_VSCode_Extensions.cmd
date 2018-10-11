@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



:: InstallExtensions
:: ---------------------------------------------------------------------------------------------
:InstallExtensions
Echo.
Call code "--install-extension" "Angular.ng-template"
Call code "--install-extension" "christian-kohler.path-intellisense"
Call code "--install-extension" "dbaeumer.vscode-eslint"
Call code "--install-extension" "ecmel.vscode-html-css"
Call code "--install-extension" "EditorConfig.EditorConfig"
Call code "--install-extension" "eg2.tslint"
Call code "--install-extension" "eg2.vscode-npm-script"
Call code "--install-extension" "Gruntfuggly.todo-tree"
Call code "--install-extension" "isudox.vscode-jetbrains-keybindings"
Call code "--install-extension" "michelemelluso.code-beautifier"
Call code "--install-extension" "mike-co.import-sorter"
Call code "--install-extension" "rexebin.dracula"
Call code "--install-extension" "Tyriar.sort-lines"



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
