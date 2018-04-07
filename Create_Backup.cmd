@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



Echo Before first run on the new OS, run "GDrive.exe list" to accept API key



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Set /P ArchivePwd=Archive password: 


Set Utils_Path=D:\Programs

Set Date=%Date:~-10%
Set Date=%Date:/=.%



:: Cleanup
:: ---------------------------------------------------------------------------------------------
:Cleanup
Echo.
For /D %%I In (
    "D:\Games\Minecraft\Instances\*"
) Do (
    RD /S /Q "%%I\backups" ^
    & RD /S /Q "%%I\crash-reports" ^
    & RD /S /Q "%%I\logs" ^
    & Erase /F /S /Q /A ^
    & Erase /F /S /Q /A "%%I\hs_err_pid*.log" ^
    & Erase /F /S /Q /A "%%I\journeymap\data\Death*.json" ^
    & Erase /F /S /Q /A "%%I\saves\inventory-*-death-*.dat" ^
    & Erase /F /S /Q /A "%%I\saves\inventory-*-grave-*.dat" ^
    & Erase /F /S /Q /A "%%I\saves\*graveLogs.log"
)



:: Archivate
:: ---------------------------------------------------------------------------------------------
:Archivate
Echo.
Start "7-Zip" /D "%ProgramFiles%\7-Zip" /B /Wait "%ProgramFiles%\7-Zip\7z.exe" a -mx=5 -mm=Deflate -p%ArchivePwd% -r -sccUTF-8 -spf -ssw -tzip -y -- ^
    "D:\%Date%.zip" ^
    "D:\Downloads" ^
    "D:\Drivers" ^
    "D:\Games\Minecraft" ^
    "D:\Information" ^
    "D:\Installers" ^
    "D:\Programs" ^
    "D:\Projects" ^
    "D:\Scripts"



::DeleteOld
::Using a `Call` command with the label inside the `For ... In (...)` does not work in CMD (without big workarounds).
::So no something like `Call :ExecuteCommand -args` used below.
:: ---------------------------------------------------------------------------------------------
:DeleteOld
Echo.
For /F "UseBackQ Tokens=1 Delims= " %%I In (
    `Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" list --max "0" --name-width "0" --absolute ^
        ^| FindStr /I "Backups.*zip"`
) Do (
    Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" delete "%%I"
)



::UploadNew
:: ---------------------------------------------------------------------------------------------
:UploadNew
Echo.
For /F "UseBackQ Tokens=1 Delims= " %%I In (
    `Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" list --max "0" --name-width "0" --absolute ^
        ^| FindStr /I "Backups"`
) Do (
    Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" upload --parent "%%I" --delete "D:\%Date%.zip"
)



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
