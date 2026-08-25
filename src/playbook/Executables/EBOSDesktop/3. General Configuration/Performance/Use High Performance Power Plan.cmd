@echo off
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c > nul

echo.
echo The High Performance power plan is now active.
echo Press any key to exit...
pause > nul
exit /b
