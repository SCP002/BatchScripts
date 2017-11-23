@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0

Echo Before first run on the new OS, execute in the mod project folder next command:
Echo Call "<Project_Folder>\gradlew.bat" setupDecompWorkspace idea


:: Variables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Echo Press ^<Enter^> to set default value
Set /P Project_Folder=Project folder: 

If "%Project_Folder%" Equ "" (
    Set Project_Folder=D:\Projects\DropOff
)

Echo.
Echo Project folder: %Project_Folder%
Echo.
Pause

Set Build_Folder=%Project_Folder%\build\libs


:: Build
:: ---------------------------------------------------------------------------------------------
:Build
Echo.
CD /D "%Project_Folder%"
Erase /F /Q /A "%Build_Folder%\*.jar"
Erase /F /Q /A "%Project_Folder%\*.jar"

Call "%Project_Folder%\gradlew.bat" build

XCopy "%Build_Folder%\*.jar" "%Project_Folder%\" /C /I /Q /G /H /R /K /Y /Z >Nul


:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
