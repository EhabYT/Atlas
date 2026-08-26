@echo off
title EBOS Dashboard
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Dashboard.ps1"
if not "%ERRORLEVEL%"=="0" pause
