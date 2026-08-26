@echo off
setlocal

echo Windows Memory Diagnostic requires a restart to test RAM.
choice /c YN /m "Open Windows Memory Diagnostic"
if errorlevel 2 exit /b

start "" mdsched.exe
