@echo off
setlocal

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f > nul
reg add "HKCU\Software\Microsoft\Windows\DWM" /v ColorPrevalence /t REG_DWORD /d 0 /f > nul

echo Liquid Glass visual effects have been disabled for the current user.
echo Restarting Explorer to refresh the interface...
taskkill /f /im explorer.exe > nul 2>&1
start "" explorer.exe
