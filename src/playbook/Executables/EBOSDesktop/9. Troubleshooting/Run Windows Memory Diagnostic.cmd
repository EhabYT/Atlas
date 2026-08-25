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

echo Windows Memory Diagnostic tests your RAM for errors.
echo Your computer will restart and the test will run before Windows starts.
echo]
choice /c:yn /n /m "Would you like to schedule the memory diagnostic and restart now? [Y/N] "
if %errorlevel% neq 1 exit /b

start "" mdsched.exe
exit /b
