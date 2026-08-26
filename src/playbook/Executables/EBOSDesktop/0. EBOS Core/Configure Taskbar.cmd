@echo off
title EBOS Taskbar
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Taskbar.ps1" -Status
echo.
echo Examples:
echo   -Align center   -Align left
echo   -Size small     -Size default   -Size large
echo   -MultiMonitor on  -MultiMonitor primary
echo   -Reset  (restore Windows defaults)
set /p args="Enter options: "
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Taskbar.ps1" %args%
pause
