@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



Echo Before first run on the new OS, run "GDrive.exe about" to perform authentication



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Echo SetVariables...

Set MC_Path=D:\Games\Minecraft
Set Utils_Path=D:\Programs

Set Archive_Name=%Date:~-10%
Set Archive_Name=%Archive_Name:/=.%

Set Exit_Color=0A



:: ArchiveCheck
:: ---------------------------------------------------------------------------------------------
:ArchiveCheck
Echo.
Echo ArchiveCheck...

If Exist "D:\%Archive_Name%.zip" (
    GoTo GetOldID
)



:: Cleanup
:: ---------------------------------------------------------------------------------------------
:Cleanup
Echo.
Echo Cleanup...

RD /S /Q "%MC_Path%\crash-reports"
RD /S /Q "%MC_Path%\logs"

Erase /F /S /Q /A "%MC_Path%\hs_err_pid*.log"



:: Archivate
:: ---------------------------------------------------------------------------------------------
:Archivate
Echo.
Echo Archivate...

Set /P Archive_Pwd=Archive password: 


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
Echo GetOldID...

For /F "UseBackQ Tokens=1 Delims= " %%I In (
    `Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" list --max "0" --name-width "0" --absolute ^
    ^| FindStr /R /C:".*Backups\\.*\.zip.*bin.*"`
) Do (
    Set Old_ID=%%I
)



:: UploadNew
:: ---------------------------------------------------------------------------------------------
:UploadNew
Echo.
Echo UploadNew...

For /F "UseBackQ Tokens=1 Delims= " %%I In (
    `Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" list --max "0" --name-width "0" --absolute ^
    ^| FindStr /R /C:".*Backups.*dir.*"`
) Do (
    Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" upload --parent "%%I" "D:\%Archive_Name%.zip" ^
    | FindStr /R /C:"Uploaded .* at .*, total .*" ^
    || Set Upload_Failed=True
)



:: UploadCheck
:: ---------------------------------------------------------------------------------------------
:UploadCheck
Echo.
Echo UploadCheck...

If "%Upload_Failed%" Equ "True" (
    Set Exit_Color=0C
    GoTo Exit
)



:: DeleteOld
:: ---------------------------------------------------------------------------------------------
:DeleteOld
Echo.
Echo DeleteOld...

Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" delete "%Old_ID%"



:: DeleteLocal
:: ---------------------------------------------------------------------------------------------
:DeleteLocal
Echo.
Echo DeleteLocal...

Erase /F /Q /A "D:\%Archive_Name%.zip"



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
Echo.
Echo Exit...

PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color %Exit_Color%
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
