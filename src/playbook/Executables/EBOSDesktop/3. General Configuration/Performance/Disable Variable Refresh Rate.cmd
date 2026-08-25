@echo off
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v DirectXUserGlobalSettings /t REG_SZ /d "VRROptimizeEnable=0;" /f > nul

echo.
echo Variable Refresh Rate has been disabled.
echo Press any key to exit...
pause > nul
exit /b
