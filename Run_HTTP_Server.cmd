@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Echo SetVariables...

Echo Searching for Python executable...

For /F "UseBackQ" %%I In (
    `Dir /A /B /S "%SystemDrive%\python.exe" ^
        ^| FindStr /R /C:".*\\Python3.\\python\.exe"`
) Do (
    Set Python_Exec=%%I
)

If "%Python_Exec%" Equ "" (
    Echo Python executable not found, aborting.
    GoTo Exit
)

Echo Python executable found: "%Python_Exec%"


Echo.
Echo Press ^<Enter^> to set default value
Set /P Share_Path=Path to share: 
Set /P Port=Port: 


If "%Share_Path%" Equ "" (
    Set Share_Path=D:\Downloads
)

If "%Port%" Equ "" (
    Set Port=80
)


Echo.
For /F "UseBackQ Tokens=2 Delims=:" %%I In (
    `IPConfig /All ^
        ^| FindStr /R /C:".*IPv4 Address.*"`
) Do (
    Echo Local IP address:%%I
)
Echo Path to share: %Share_Path%
Echo Port: %Port%
Echo.
Pause



:: Run
:: ---------------------------------------------------------------------------------------------
:Run
Echo.
Echo Run...

Start "HTTPServer" /D "%Share_Path%" /B /Wait "%Python_Exec%" -m "http.server" "%Port%"



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit

PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
