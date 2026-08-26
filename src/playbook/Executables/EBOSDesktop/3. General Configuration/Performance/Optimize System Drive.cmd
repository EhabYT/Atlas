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

echo Optimizing %SystemDrive% using Windows Optimize Drives...
echo SSDs are retrimmed; hard drives are defragmented when appropriate.
defrag.exe %SystemDrive% /O /U

echo.
echo Drive optimization has finished.
pause
