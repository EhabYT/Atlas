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

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f > nul

echo Power throttling has been disabled.
echo This may increase power use and heat output, especially on laptops.
pause
