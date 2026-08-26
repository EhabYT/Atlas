@echo off
setlocal

powercfg.exe /setactive SCHEME_BALANCED
if errorlevel 1 (
    echo Windows could not activate the Balanced power plan.
    pause
    exit /b 1
)

echo The Windows Balanced power plan is now active.
pause
