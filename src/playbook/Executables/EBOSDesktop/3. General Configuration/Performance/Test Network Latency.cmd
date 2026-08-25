@echo off
title Test Network Latency

if defined EBOS_NETWORK_HOST (set "host=%EBOS_NETWORK_HOST%") else (set "host=1.1.1.1")

echo Testing network latency to %host% (10 pings)...
echo.
powershell -NoProfile -Command "Test-Connection -Target '%host%' -Count 10 | Format-Table -AutoSize"

echo.
echo Press any key to exit...
pause > nul
exit /b
