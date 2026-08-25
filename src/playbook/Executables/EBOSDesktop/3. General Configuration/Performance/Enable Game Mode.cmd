@echo off
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f > nul

echo.
echo Game Mode has been enabled.
echo Press any key to exit...
pause > nul
exit /b
