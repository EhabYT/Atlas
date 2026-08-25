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

echo Optimizing the system drive (retrim/defragment)...
defrag.exe %SystemDrive% /O /U

echo.
echo The system drive has been optimized.
echo Press any key to exit...
pause > nul
exit /b
