@echo off
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v DirectXUserGlobalSettings /t REG_SZ /d "VRROptimizeEnable=1;" /f > nul

echo.
echo Variable Refresh Rate has been enabled.
echo Press any key to exit...
pause > nul
exit /b
