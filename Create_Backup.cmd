@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



Echo Before first run on the new OS, run "GDrive.exe list" to accept API key



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Set /P Archive_Pwd=Archive password: 


Set MC_Path=D:\Games\Minecraft
Set Utils_Path=D:\Programs

Set Archive_Name=%Date:~-10%
Set Archive_Name=%Archive_Name:/=.%

Set Exit_Color=0A



:: ArchiveCheck
:: ---------------------------------------------------------------------------------------------
:ArchiveCheck
Echo.
If Exist "D:\%Archive_Name%.zip" (
    GoTo GetOldID
)



:: Cleanup
:: ---------------------------------------------------------------------------------------------
:Cleanup
Echo.
RD /S /Q "%MC_Path%\crash-reports"
RD /S /Q "%MC_Path%\logs"

Erase /F /S /Q /A "%MC_Path%\hs_err_pid*.log"



:: Archivate
:: ---------------------------------------------------------------------------------------------
:Archivate
Echo.
Start "7-Zip" /D "%ProgramFiles%\7-Zip" /B /Wait "%ProgramFiles%\7-Zip\7z.exe" a -mx=5 -mm=Deflate -p%Archive_Pwd% -r -sccUTF-8 -spf -ssw -tzip -y -- ^
    "D:\%Archive_Name%.zip" ^
    "D:\Downloads" ^
    "D:\Drivers" ^
    "D:\Games\Minecraft" ^
    "D:\Information" ^
    "D:\Installers" ^
    "D:\Programs" ^
    "D:\Projects" ^
    "D:\Scripts"



:: GetOldID
:: ---------------------------------------------------------------------------------------------
:GetOldID
Echo.
For /F "UseBackQ Tokens=1 Delims= " %%I In (
    `Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" list --max "0" --name-width "0" --absolute ^
        ^| FindStr /I ".*Backups\\.*\.zip.*bin.*"`
) Do (
    Set Old_ID=%%I
)



:: UploadNew
:: ---------------------------------------------------------------------------------------------
:UploadNew
Echo.
For /F "UseBackQ Tokens=1 Delims= " %%I In (
    `Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" list --max "0" --name-width "0" --absolute ^
        ^| FindStr /I ".*Backups.*dir.*"`
) Do (
    Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" upload --parent "%%I" "D:\%Archive_Name%.zip" ^
    & Set Upload_Error_Level=%ErrorLevel%
)



:: UploadCheck
:: ---------------------------------------------------------------------------------------------
:UploadCheck
Echo.
If "%Upload_Error_Level%" Neq "0" (
    Set Exit_Color=0C ^
    & GoTo Exit
)



:: DeleteOld
:: ---------------------------------------------------------------------------------------------
:DeleteOld
Echo.
Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" delete "%Old_ID%"



:: DeleteLocal
:: ---------------------------------------------------------------------------------------------
:DeleteLocal
Echo.
Erase /F /Q /A "D:\%Archive_Name%.zip"



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color %Exit_Color%
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
