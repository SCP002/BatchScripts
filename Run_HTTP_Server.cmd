@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0


:: Variables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo Press ^<Enter^> to set default value
Set /P Share_Folder=Folder to share: 
Set /P Port=Port: 

If "%Share_Folder%" Equ "" (
    Set Share_Folder=D:\Downloads
)

If "%Port%" Equ "" (
    Set Port=80
)

Echo.
For /F "UseBackQ Tokens=2 Delims=:" %%I In (
    `IPConfig /All ^| FindStr /I "IPv4"`
) Do (
    Echo Local IP address:%%I
)
Echo Folder to share: %Share_Folder%
Echo Port: %Port%
Echo.
Pause

Set Python_Folder=%LocalAppData%\Programs\Python\Python36


:: Run
:: ---------------------------------------------------------------------------------------------
:Run
Echo.
Start "HTTPServer" /D "%Share_Folder%" /B /Wait "%Python_Folder%\python.exe" -m "http.server" "%Port%"


:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
