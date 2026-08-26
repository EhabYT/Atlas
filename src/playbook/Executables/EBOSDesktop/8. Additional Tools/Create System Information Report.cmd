@echo off
setlocal

set "reportPath=%USERPROFILE%\Desktop\EBOS-System-Information.txt"

echo Creating a system information report...
msinfo32.exe /report "%reportPath%"
if errorlevel 1 (
    echo The system information report could not be created.
    pause
    exit /b 1
)

echo Report created:
echo %reportPath%
pause
