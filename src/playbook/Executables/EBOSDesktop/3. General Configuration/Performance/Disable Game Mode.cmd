@echo off
setlocal

reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 0 /f > nul

echo Game Mode has been disabled for the current user.
echo Restart any running games for the setting to take effect.
pause
