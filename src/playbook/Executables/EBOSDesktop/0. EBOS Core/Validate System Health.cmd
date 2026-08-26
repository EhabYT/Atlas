@echo off
title EBOS System Validation
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Validate.ps1"
echo.
echo Report saved to %WINDIR%\EBOSModules\Other\validation-report.txt
pause
