@echo off
title EBOS System Report
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Detect.ps1" -WriteReport
echo.
echo Report saved to %WINDIR%\EBOSModules\Other\system-report.txt
pause
