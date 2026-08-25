@echo off
ipconfig /flushdns

echo.
echo The DNS cache has been flushed.
echo Press any key to exit...
pause > nul
exit /b
