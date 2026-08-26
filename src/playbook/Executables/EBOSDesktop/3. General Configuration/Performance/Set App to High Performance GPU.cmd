@echo off
setlocal

powershell -NoProfile -STA -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.Title = 'Choose an application'; $dialog.Filter = 'Applications (*.exe)|*.exe'; if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; New-Item -Path $path -Force ^| Out-Null; Set-ItemProperty -Path $path -Name $dialog.FileName -Value 'GpuPreference=2;'; [System.Windows.Forms.MessageBox]::Show('The high-performance GPU preference has been set for:' + [Environment]::NewLine + $dialog.FileName, 'EBOS Performance') ^| Out-Null }"
