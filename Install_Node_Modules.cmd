@Echo Off
ChCp 65001 >Nul
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



:: InstallNodeModules
:: ---------------------------------------------------------------------------------------------
:InstallNodeModules
Echo.
Echo InstallNodeModules...

Call "%ProgramFiles%\nodejs\npm.cmd" install --global typescript
Call "%ProgramFiles%\nodejs\npm.cmd" install --global ts-node
Call "%ProgramFiles%\nodejs\npm.cmd" install --global @types/node
Call "%ProgramFiles%\nodejs\npm.cmd" install --global @angular/cli



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit

PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
