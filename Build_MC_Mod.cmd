@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0


:: Variables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo Searching for Git executable...

For /F "UseBackQ" %%I In (
    `Dir /A /B /S "%SystemDrive%\git.exe" ^| FindStr /I "cmd\\git\.exe"`
) Do (
    Set Git_Exec=%%I
)

If "%Git_Exec%" Equ "" (
    Echo Git executable not found, aborting. ^
    & GoTo Exit
)

Echo Git executable found: "%Git_Exec%"

Echo.
Echo Press ^<Enter^> to set default value
Set /P Repo_Path=Repository path: 

If "%Repo_Path%" Equ "" (
    Set Repo_Path=D:\Projects\DropOff
)

CD /D "%Repo_Path%"

Echo.
Echo Repository path: %Repo_Path%
Echo | Set /P X=Current branch: 
Start "Git" /D "%Repo_Path%" /B /Wait "%Git_Exec%" branch | FindStr /I "\*"
Echo.
Pause

Set Build_Path=%Repo_Path%\build\libs


:: Build
:: ---------------------------------------------------------------------------------------------
:Build
Echo.
Erase /F /Q /A "%Build_Path%\*.jar"
Erase /F /Q /A "%Repo_Path%\*.jar"

Call "%Repo_Path%\gradlew.bat" build

XCopy "%Build_Path%\*.jar" "%Repo_Path%\" /C /I /Q /G /H /R /K /Y /Z >Nul


:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
