@echo off
setlocal

fltmc > nul 2>&1 || (
    echo Administrator privileges are required.
    powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath 'cmd.exe' -ArgumentList '/c ""%~f0""'" 2> nul
    if errorlevel 1 (
        echo Unable to request administrator privileges.
        pause
    )
    exit /b
)

echo Setting Cloudflare DNS on active physical network adapters...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$adapters = Get-NetAdapter -Physical ^| Where-Object Status -eq 'Up'; if (!$adapters) { throw 'No active physical network adapter was found.' }; $adapters ^| Set-DnsClientServerAddress -ServerAddresses @('1.1.1.1','1.0.0.1')"
if errorlevel 1 (
    echo DNS settings were not changed.
    pause
    exit /b 1
)

echo Cloudflare DNS has been set for active physical adapters.
echo Use "Restore Automatic DNS" to return to the network default.
pause
