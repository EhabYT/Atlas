@echo off
powercfg /batteryreport /output "%USERPROFILE%\Desktop\EBOS-Battery-Report.html" > nul 2>&1

if exist "%USERPROFILE%\Desktop\EBOS-Battery-Report.html" (
    echo.
    echo Battery report saved to your Desktop as 'EBOS-Battery-Report.html'.
    echo Press any key to open it...
    pause > nul
    start "" "%USERPROFILE%\Desktop\EBOS-Battery-Report.html"
) else (
    echo.
    echo Failed to create the battery report.
    echo A battery might not be present on this device.
    pause
)
exit /b
