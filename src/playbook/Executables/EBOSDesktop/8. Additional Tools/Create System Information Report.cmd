@echo off
echo Creating a system information report, this might take a while...
msinfo32 /report "%USERPROFILE%\Desktop\EBOS-System-Information.txt"

echo.
echo System information report saved to your Desktop as 'EBOS-System-Information.txt'.
echo Press any key to exit...
pause > nul
exit /b
