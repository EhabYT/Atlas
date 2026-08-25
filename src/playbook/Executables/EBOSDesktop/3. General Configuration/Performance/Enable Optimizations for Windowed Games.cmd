@echo off
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v DirectXUserGlobalSettings /t REG_SZ /d "SwapEffectUpgradeEnable=1;" /f > nul

echo.
echo Optimizations for windowed games have been enabled.
echo Press any key to exit...
pause > nul
exit /b
