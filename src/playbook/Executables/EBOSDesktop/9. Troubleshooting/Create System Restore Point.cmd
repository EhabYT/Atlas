@echo off
set "___args="%~f0" %*"
fltmc > nul 2>&1 || (
    echo Administrator privileges are required.
    powershell -c "Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList """/c $env:___args"""" 2> nul || (
        echo You must run this script as admin.
        if "%*"=="" pause
        exit /b 1
    )
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Enable-ComputerRestore -Drive $env:SystemDrive; Checkpoint-Computer -Description 'EBOS manual restore point' -RestorePointType 'MODIFY_SETTINGS'"

echo.
echo The system restore point has been created.
echo Press any key to exit...
pause > nul
exit /b
