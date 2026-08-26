@echo off
setlocal

set "downloadUrl=https://github.com/EhabYT/EB-Tool/releases/download/EBTool/eb-tool-Setup.exe"
set "installerPath=%TEMP%\eb-tool-Setup.exe"

echo Downloading EB Tool...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%downloadUrl%' -OutFile '%installerPath%'"
if errorlevel 1 (
    echo The EB Tool download failed.
    pause
    exit /b 1
)

echo Starting the EB Tool installer...
start "" "%installerPath%"
