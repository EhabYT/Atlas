@echo off
title EBOS Rollback
powershell -NoP -EP Bypass -File "%WINDIR%\EBOSModules\Core\EBOS-Rollback.ps1" -List
echo.
echo To restore the newest backup run:
echo   powershell -File %%WINDIR%%\EBOSModules\Core\EBOS-Rollback.ps1 -Latest
echo To undo the last taskbar/profile/glass change run:
echo   powershell -File %%WINDIR%%\EBOSModules\Core\EBOS-Rollback.ps1 -UndoChangeSet taskbar
pause
