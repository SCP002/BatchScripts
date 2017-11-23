@Echo Off
ChCp 65001
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0

Echo Before first run on the new OS, launch "PuTTY" to accept SSH key
Echo Execute "sudo mkdir -m 777 %Destination_Path%" on the server to create site folder with proper access level


:: Variables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Set /P Login=Login: 
Set /P Password=Password: 

Echo.
Echo Press ^<Enter^> to set default value
Set /P Address=Address: 
Set /P Source_Path=Source path: 
Set /P Destination_Path=Destination path: 

If "%Address%" Equ "" (
    Set Address=10.31.255.80
)
If "%Source_Path%" Equ "" (
    Set Source_Path=D:\Projects\WebPlus\SKS\Release
)
If "%Destination_Path%" Equ "" (
    Set Destination_Path=/var/www/html/sks
)

Echo.
Echo Address: %Address%
Echo Source path: %Source_Path%
Echo Destination path: %Destination_Path%
Echo.
Pause

Set Utils_Path=D:\Programs


:: Upload
:: ---------------------------------------------------------------------------------------------
:Upload
Echo.
Call :ExecuteCommand "sudo /sbin/service httpd stop"
Call :ExecuteCommand "sudo rm -r -f \"%Destination_Path%/*\""

XCopy "D:\Projects\WebPlus\SKS\Miscellaneous\*.m3u" "D:\Projects\WebPlus\SKS\Release\assets\files\" /C /I /Q /G /H /R /K /Y /Z >Nul
Call :UploadFiles "%Source_Path%" "%Destination_Path%"
Call :ExecuteCommand "sudo /sbin/service httpd start"

RmDir /S /Q "%Source_Path%" && MkDir "%Source_Path%"


:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit
PowerShell -Command "& { [System.Console]::Beep(500, 1000); }"
Color 0A
Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0


:: Functions
:: ---------------------------------------------------------------------------------------------
:ExecuteCommand
    SetLocal
    Set Command=%~1

    Start "PLink" /D "%Utils_Path%" /B /Wait "%Utils_Path%\PLink.exe" -ssh -l "%Login%" -batch -pw "%Password%" -t "%Address%" "%Command%"

    EndLocal
Exit /B 0

:UploadFiles
    SetLocal
    Set Source_Path=%~1
    Set Destination_Path=%~2

    Start "PSCP" /D "%Utils_Path%" /B /Wait "%Utils_Path%\PSCP.exe" -q -r -l "%Login%" -pw "%Password%" -batch -unsafe "%Source_Path%\*" "%Address%":"%Destination_Path%/"

    EndLocal
Exit /B 0
