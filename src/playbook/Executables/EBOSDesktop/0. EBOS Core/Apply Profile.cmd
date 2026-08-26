@echo off
title EBOS Profiles
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Profiles.ps1" -List
echo.
set /p p="Profile to apply: "
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Profiles.ps1" -Apply %p%
pause
