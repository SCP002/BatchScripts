@Echo Off
ChCp 65001 >Nul
SetLocal DisableDelayedExpansion EnableExtensions
Title %~0



:: CheckAdminPermissions
:: ---------------------------------------------------------------------------------------------
:CheckAdminPermissions
Echo CheckAdminPermissions...

Net Session >Nul 2>&1

If "%ErrorLevel%" Neq "0" (
    Echo Script needs to be runned as administrator
    GoTo Exit
)

CD /D "%~dp0"



:: SetVariables
:: ---------------------------------------------------------------------------------------------
:SetVariables
Echo.
Echo SetVariables...

Set VPN_Service=SEVPNCLIENT
Set VPN_Adapter=VPN - VPN Client
Set VPN_Client_Path=%ProgramFiles%\SoftEther VPN Client



:: ConfigureServices
:: ---------------------------------------------------------------------------------------------
:ConfigureServices
Echo.
Echo ConfigureServices...

SC Config "%VPN_Service%" Start= Demand >Nul



:: StartVPNClient
:: ---------------------------------------------------------------------------------------------
:StartVPNClient
Echo.
Echo StartVPNClient...

SC Start "%VPN_Service%" >Nul

Netsh Interface Set Interface "%VPN_Adapter%" Enable

Start "VPN Client" /D "%VPN_Client_Path%" /B "%VPN_Client_Path%\vpncmgr_x64.exe"

Echo Press any key to stop VPN client...
Pause >Nul



:: StopVPNClient
:: ---------------------------------------------------------------------------------------------
:StopVPNClient
Echo.
Echo StopVPNClient...

SC Stop "%VPN_Service%" >Nul

Netsh Interface Set Interface "%VPN_Adapter%" Disable



:: Exit
:: ---------------------------------------------------------------------------------------------
:Exit

Echo.
Echo Done. Press any key to exit...
Pause >Nul
Exit /B 0
