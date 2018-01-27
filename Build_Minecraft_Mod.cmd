@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0


:: Variables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo Press ^<Enter^> to set default value
Set /P Project_Path=Project path: 

If "%Project_Path%" Equ "" (
    Set Project_Path=D:\Projects\DropOff
)

Echo.
Echo Project path: %Project_Path%
Echo.
Pause

Set Build_Path=%Project_Path%\build\libs


:: Build
:: ---------------------------------------------------------------------------------------------
:Build
Echo.
CD /D "%Project_Path%"
Erase /F /Q /A "%Build_Path%\*.jar"
Erase /F /Q /A "%Project_Path%\*.jar"

Call "%Project_Path%\gradlew.bat" build

XCopy "%Build_Path%\*.jar" "%Project_Path%\" /C /I /Q /G /H /R /K /Y /Z >Nul


:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
