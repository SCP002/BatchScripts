@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo Press ^<Enter^> to set default value
Set /P Project_Path=Project path: 

If "%Project_Path%" Equ "" (
    Set Project_Path=D:\Projects\DropOff
)

CD /D "%Project_Path%"


Echo.
Echo Project path: %Project_Path%
Echo.
Pause



:: Setup
:: ---------------------------------------------------------------------------------------------
:Setup
Echo.
Call "%Project_Path%\gradlew.bat" clean setupDecompWorkspace idea



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
