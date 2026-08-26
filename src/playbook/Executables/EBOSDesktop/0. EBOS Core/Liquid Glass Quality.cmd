@echo off
title EBOS Liquid Glass
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Glass.ps1" -Status
echo.
echo Tiers: Ultra, High, Balanced, Performance, Compatibility
echo (blank = automatic hardware/battery/accessibility-aware selection)
set /p q="Quality: "
if "%q%"=="" (powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Glass.ps1" -Auto) else (powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Glass.ps1" -Quality %q%)
pause
