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

echo Restoring automatic DNS on active physical network adapters...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$adapters = Get-NetAdapter -Physical ^| Where-Object Status -eq 'Up'; if (!$adapters) { throw 'No active physical network adapter was found.' }; $adapters ^| Set-DnsClientServerAddress -ResetServerAddresses"
if errorlevel 1 (
    echo DNS settings were not changed.
    pause
    exit /b 1
)

echo Automatic DNS has been restored for active physical adapters.
pause
