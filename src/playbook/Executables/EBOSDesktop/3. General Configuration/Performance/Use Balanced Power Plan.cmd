@echo off
powercfg /setactive SCHEME_BALANCED > nul

echo.
echo The Balanced power plan is now active.
echo Press any key to exit...
pause > nul
exit /b
