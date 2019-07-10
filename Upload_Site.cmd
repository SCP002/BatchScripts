@Echo Off
ChCp 65001 >Nul
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



Echo Before first run on the new OS, launch "PuTTY" to accept SSH key
Echo Make sure you have ".htaccess" files enabled
Echo Make sure you have user added to sudo group and sudoers file



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Echo SetVariables...

Set /P Login=Login: 
Set /P Password=Password: 


Echo.
Echo Press ^<Enter^> to set default value
Set /P Address=Address: 
Set /P Port=Port: 
Set /P Source_Path=Source path: 
Set /P Destination_Path=Destination path: 
Set /P PSCP_Protocol=PSCP protocol (sftp / scp): 


If "%Address%" Equ "" (
    Set Address=10.31.255.10
)
If "%Port%" Equ "" (
    Set Port=922
)
If "%Source_Path%" Equ "" (
    Set Source_Path=D:\Projects\SKS
)
If "%Destination_Path%" Equ "" (
    Set Destination_Path=/var/www/sks
)
If "%PSCP_Protocol%" Equ "" (
    Set PSCP_Protocol=sftp
)


Set Utils_Path=D:\Programs


Echo.
Echo Address: %Address%
Echo Port: %Port%
Echo Source path: %Source_Path%
Echo Destination path: %Destination_Path%
Echo PSCP protocol: %PSCP_Protocol%
Echo.
Pause



:: Upload
:: ---------------------------------------------------------------------------------------------
:Upload
Echo.
Echo Upload...

:: Call :ExecuteCommand "sudo /etc/init.d/apache2 stop"


Call :ExecuteCommand "sudo rm -rf %Destination_Path%"

Call :ExecuteCommand "sudo mkdir %Destination_Path%"
Call :ExecuteCommand "sudo chmod -R 777 %Destination_Path%"
Call :ExecuteCommand "sudo chown -R %Login% %Destination_Path%"


Call :UploadFiles "%Source_Path%" "%Destination_Path%"


:: Call :ExecuteCommand "sudo /etc/init.d/apache2 start"



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

    Start "PLink" /D "%Utils_Path%" /B /Wait "%Utils_Path%\PLink.exe" -ssh -P "%Port%" -l "%Login%" -batch -pw "%Password%" -t "%Address%" "%Command%"

    EndLocal
Exit /B 0


:UploadFiles
    SetLocal
    Set Source_Path=%~1
    Set Destination_Path=%~2

    Start "PSCP" /D "%Utils_Path%" /B /Wait "%Utils_Path%\PSCP.exe" -q -r -P "%Port%" -l "%Login%" -pw "%Password%" -batch -unsafe -%PSCP_Protocol% "%Source_Path%\*" "%Address%":"%Destination_Path%"

    EndLocal
Exit /B 0
