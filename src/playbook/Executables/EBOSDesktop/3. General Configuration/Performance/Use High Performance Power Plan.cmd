@echo off
setlocal

powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
if errorlevel 1 (
    echo Windows could not activate the High Performance power plan.
    echo Use the EBOS power-saving controls if you need a custom performance plan.
    pause
    exit /b 1
)

echo The Windows High Performance power plan is now active.
echo This can increase power use and heat output.
pause
