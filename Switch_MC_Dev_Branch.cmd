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
Echo Target repository: %Repo_Path%
Echo Available branches:
Start "Git" /D "%Repo_Path%" /B /Wait "%Git_Exec%" branch

Echo.
Set /P Target_Branch=Branch to switch to: 

If "%Target_Branch%" Equ "" (
    Set Target_Branch=master
)

Echo.
Echo Target branch: %Target_Branch%
Echo.
Pause


:: SwitchBranch
:: ---------------------------------------------------------------------------------------------
:SwitchBranch
Echo.
Start "Git" /D "%Repo_Path%" /B /Wait "%Git_Exec%" checkout "%Target_Branch%"


:: RebuildDevEnv
:: ---------------------------------------------------------------------------------------------
Echo.
Call "%Repo_Path%\gradlew.bat" clean setupDecompWorkspace idea
:: ---------------------------------------------------------------------------------------------


:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
