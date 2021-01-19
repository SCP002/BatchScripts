@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



Echo Before first run on the new OS, run "GDrive.exe --oauth-credentials GDriveOAuth.json about" to perform authentication



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Echo SetVariables...

Set MC_Path=D:\Games\Minecraft
Set WoW_Path=D:\Games\World of Warcraft
Set Utils_Path=D:\Programs
Set Projects_Path=D:\Projects

Set Archive_Name=%Date:~-10%
Set Archive_Name=%Archive_Name:/=.%

Set Backups_Max_Amount=3
Set Backups_Counter=0

Set Current_Error_Code=0



:: ArchiveCheck
:: ---------------------------------------------------------------------------------------------
:ArchiveCheck
Echo.
Echo ArchiveCheck...

If Exist "D:\%Archive_Name%.zip" (
    GoTo UploadNew
)



:: PromptArchivePassword
:: ---------------------------------------------------------------------------------------------
:PromptArchivePassword
Echo.
Echo PromptArchivePassword...

Set /P Archive_Pwd=Archive password: 



:: Cleanup
:: ---------------------------------------------------------------------------------------------
:Cleanup
Echo.
Echo Cleanup...

Erase /F /S /Q /A "%MC_Path%\*.bak"
Erase /F /S /Q /A "%MC_Path%\*.dat_old"
Erase /F /S /Q /A "%MC_Path%\class_cache.zip"
Erase /F /S /Q /A "%MC_Path%\hs_err_pid*.log"
Erase /F /S /Q /A "%MC_Path%\usercache.json"


For /F "UseBackQ" %%I In (
    `Dir /A:D /B /S "%MC_Path%\backups"`
) Do (
    RD /S /Q "%%I"
)

For /F "UseBackQ" %%I In (
    `Dir /A:D /B /S "%MC_Path%\crash-reports"`
) Do (
    RD /S /Q "%%I"
)

For /F "UseBackQ" %%I In (
    `Dir /A:D /B /S "%MC_Path%\logs"`
) Do (
    RD /S /Q "%%I"
)


Erase /F /S /Q /A "%WoW_Path%\_retail_\WTF\*.bak"
Erase /F /S /Q /A "%WoW_Path%\_retail_\WTF\*.old"
Erase /F /S /Q /A "%WoW_Path%\_retail_\WTF\bindings-cache.wtf"
Erase /F /S /Q /A "%WoW_Path%\_retail_\WTF\cache.md5"
Erase /F /S /Q /A "%WoW_Path%\_retail_\WTF\chat-cache.txt"
Erase /F /S /Q /A "%WoW_Path%\_retail_\WTF\config-cache.wtf"
Erase /F /S /Q /A "%WoW_Path%\_retail_\WTF\macros-cache.txt"


For /F "UseBackQ" %%I In (
    `Dir /A:D /B /S "%Projects_Path%\.mypy_cache"`
) Do (
    RD /S /Q "%%I"
)

For /F "UseBackQ" %%I In (
    `Dir /A:D /B /S "%Projects_Path%\__pycache__"`
) Do (
    RD /S /Q "%%I"
)



:: Archivate
:: ---------------------------------------------------------------------------------------------
:Archivate
Echo.
Echo Archivate...

Start "7-Zip" /D "%ProgramFiles%\7-Zip" /B /Wait "%ProgramFiles%\7-Zip\7z.exe" a -mx=5 -mm=Deflate -p%Archive_Pwd% -r -sccUTF-8 -spf -ssw -tzip -y -- ^
    "D:\%Archive_Name%.zip" ^
    "D:\Downloads" ^
    "D:\Drivers" ^
    "%MC_Path%" ^
    "%WoW_Path%\_retail_\Interface\AddOns" ^
    "%WoW_Path%\_retail_\WTF" ^
    "D:\Information" ^
    "D:\Installers" ^
    "D:\Programs" ^
    "D:\Projects" ^
    "D:\Scripts"



:: UploadNew
:: ---------------------------------------------------------------------------------------------
:UploadNew
Echo.
Echo UploadNew...

Set Current_Error_Code=1


For /F "UseBackQ Tokens=1 Delims= " %%I In (
    `Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" --oauth-credentials "%Utils_Path%\GDriveOAuth.json" list --max "0" --order "createdTime desc" --name-width "0" --absolute ^
        ^| FindStr /R /C:" *Backups *dir *"`
) Do (
    SetLocal EnableDelayedExpansion

    Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" --oauth-credentials "%Utils_Path%\GDriveOAuth.json" upload --parent "%%I" "D:\%Archive_Name%.zip" ^
        | FindStr /R /C:"^Uploaded .* at .*, total .*"

    Set Current_Error_Code=!ErrorLevel!

    SetLocal DisableDelayedExpansion
)


If "%Current_Error_Code%" Neq "0" (
    Echo.
    Echo UploadNew failed

    GoTo Exit
)



:: GetOldID
:: ---------------------------------------------------------------------------------------------
:GetOldID
Echo.
Echo GetOldID...

For /F "UseBackQ Tokens=1 Delims= " %%I In (
    `Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" --oauth-credentials "%Utils_Path%\GDriveOAuth.json" list --max "0" --order "createdTime desc" --name-width "0" --absolute ^
        ^| FindStr /R /C:" *Backups\\.*\.zip *bin *"`
) Do (
    Set /A Backups_Counter=%Backups_Counter%+1

    Set Old_ID=%%I
)


If "%Old_ID%" Equ "" (
    Set Current_Error_Code=1

    Echo.
    Echo GetOldID failed

    GoTo Exit
)



:: CheckBackupsAmount
:: ---------------------------------------------------------------------------------------------
:CheckBackupsAmount
Echo.
Echo CheckBackupsAmount...

If "%Backups_Counter%" LEQ "%Backups_Max_Amount%" (
    GoTo DeleteLocal
)



:: DeleteOld
:: ---------------------------------------------------------------------------------------------
:DeleteOld
Echo.
Echo DeleteOld...

Start "GDrive" /D "%Utils_Path%" /B /Wait "%Utils_Path%\GDrive.exe" --oauth-credentials "%Utils_Path%\GDriveOAuth.json" delete "%Old_ID%" ^
    | FindStr /R /C:"^Deleted '.*\.zip'"

Set Current_Error_Code=%ErrorLevel%


If "%Current_Error_Code%" Neq "0" (
    Echo.
    Echo DeleteOld failed

    GoTo Exit
)


:: DeleteLocal
:: ---------------------------------------------------------------------------------------------
:DeleteLocal
Echo.
Echo DeleteLocal...

Erase /F /Q /A "D:\%Archive_Name%.zip"



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit

If "%Current_Error_Code%" Neq "0" (
    Color 0C

    PowerShell -Command "& { [System.Console]::Beep(700, 500); }"
    PowerShell -Command "& { [System.Console]::Beep(500, 500); }"
) Else (
    Color 0A

    PowerShell -Command "& { [System.Console]::Beep(500, 500); }"
    PowerShell -Command "& { [System.Console]::Beep(700, 500); }"
)

Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
