@echo off
title EBOS Backup
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Backup.ps1"
pause
