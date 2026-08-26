@echo off
setlocal

set "reportPath=%USERPROFILE%\Desktop\EBOS-Battery-Report.html"

echo Creating a battery report...
powercfg.exe /batteryreport /output "%reportPath%"
if errorlevel 1 (
    echo A battery report could not be created. This device may not have a supported battery.
    pause
    exit /b 1
)

echo Report created:
echo %reportPath%
start "" "%reportPath%"
