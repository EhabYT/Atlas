@echo off
title Install EB Tool

if exist "%ProgramFiles%\EB Tool\EBTool.exe" (
    echo EB Tool seems to be installed already.
    pause
    exit /b
)

set "setupPath=%TEMP%\eb-tool-Setup.exe"
echo Downloading EB Tool...
curl.exe -LSs "https://github.com/EhabYT/EB-Tool/releases/download/EBTool/eb-tool-Setup.exe" -o "%setupPath%"
if not exist "%setupPath%" (
    echo Failed to download EB Tool. Check your internet connection.
    pause
    exit /b 1
)

echo Installing EB Tool...
start /wait "" "%setupPath%"
del /q "%setupPath%" > nul 2>&1
exit /b
