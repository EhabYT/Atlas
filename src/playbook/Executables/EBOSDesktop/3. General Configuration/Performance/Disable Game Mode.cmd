@echo off
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 0 /f > nul

echo.
echo Game Mode has been disabled.
echo Press any key to exit...
pause > nul
exit /b
