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

echo Setting Cloudflare DNS (1.1.1.1 / 1.0.0.1) on all active network adapters...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' } | Set-DnsClientServerAddress -ServerAddresses ('1.1.1.1','1.0.0.1')"

echo.
echo Cloudflare DNS has been set. Use 'Restore Automatic DNS.cmd' to revert.
echo Press any key to exit...
pause > nul
exit /b
