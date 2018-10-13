@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



Echo Be sure that source branch exist (for example, newly initialized repository has at least one commited change in master)



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Echo SetVariables...

Echo Searching for Git executable...

For /F "UseBackQ" %%I In (
    `Dir /A /B /S "%SystemDrive%\git.exe" ^
    ^| FindStr /R /C:".*\\cmd\\git\.exe"`
) Do (
    Set Git_Exec=%%I
)

If "%Git_Exec%" Equ "" (
    Echo Git executable not found, aborting.
    GoTo Exit
)

Echo Git executable found: "%Git_Exec%"


Echo.
Set /P Repo_Path=Repository path: 

CD /D "%Repo_Path%"

For /F "Delims=|" %%I In (
    "%Repo_Path%"
) Do (
    Set Repo_Name=%%~nxI
)


Echo.
Echo Target repository: %Repo_Path%
Echo Current worktrees:
Start "Git" /D "%Repo_Path%" /B /Wait "%Git_Exec%" worktree list --porcelain


Echo.
Set /P New_Branch_Name=New branch name: 

Echo.
Echo Press ^<Enter^> to set default value
Set /P From_Branch=Add worktree from branch: 

If "%From_Branch%" Equ "" (
    Set From_Branch=master
)


Set New_Worktree_Folder=../%Repo_Name%_%New_Branch_Name%


Echo.
Echo Target repository: %Repo_Path%
Echo New branch name: %New_Branch_Name%
Echo Add worktree from branch: %From_Branch%
Echo New worktree folder: %New_Worktree_Folder%
Echo.
Pause



:: AddWorktree
:: ---------------------------------------------------------------------------------------------
:AddWorktree
Echo.
Echo AddWorktree...

Start "Git" /D "%Repo_Path%" /B /Wait "%Git_Exec%" worktree add -b "%New_Branch_Name%" "%New_Worktree_Folder%" "%From_Branch%"



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit

PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
