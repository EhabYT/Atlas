@echo off
setlocal

set "host=1.1.1.1"
set /p "host=Host name or IP address to test [1.1.1.1]: "
if "%host%"=="" set "host=1.1.1.1"

set "EBOS_NETWORK_HOST=%host%"
powershell -NoProfile -Command "Test-Connection -TargetName $env:EBOS_NETWORK_HOST -Count 10 ^| Select-Object Address, ResponseTime, Status ^| Format-Table -AutoSize"
echo.
pause
