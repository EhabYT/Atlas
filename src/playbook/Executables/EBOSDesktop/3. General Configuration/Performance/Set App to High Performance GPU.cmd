@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f = New-Object System.Windows.Forms.OpenFileDialog; Add-Type -AssemblyName System.Windows.Forms; $f.Filter = 'Applications (*.exe)|*.exe'; $f.Title = 'Select an application'; if ($f.ShowDialog() -ne 'OK') { exit }; reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v $f.FileName /t REG_SZ /d "GpuPreference=2;" /f"

echo.
echo The selected app has been set to use the high performance GPU.
echo Press any key to exit...
pause > nul
exit /b
