@Echo Off
ChCp 65001 >Nul
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



:: InstallNodeModules
:: ---------------------------------------------------------------------------------------------
:InstallNodeModules
Echo.
Echo InstallNodeModules...

npm install --global typescript
npm install --global ts-node
npm install --global @types/node
npm install --global @angular/cli



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit

PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
