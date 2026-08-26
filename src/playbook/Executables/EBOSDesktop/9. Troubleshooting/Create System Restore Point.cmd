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

powershell -NoProfile -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'EBOS manual restore point' -RestorePointType MODIFY_SETTINGS"
if errorlevel 1 (
    echo A restore point could not be created.
    echo Verify that System Protection is enabled and try again later.
    pause
    exit /b 1
)

echo The EBOS restore point was created successfully.
pause
