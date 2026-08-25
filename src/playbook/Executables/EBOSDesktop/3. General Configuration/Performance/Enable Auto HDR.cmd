@echo off
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v DirectXUserGlobalSettings /t REG_SZ /d "AutoHDREnable=1;" /f > nul

echo.
echo Auto HDR has been enabled.
echo Press any key to exit...
pause > nul
exit /b
