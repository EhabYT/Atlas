@echo off
setlocal

powershell -NoProfile -STA -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.Title = 'Choose an application'; $dialog.Filter = 'Applications (*.exe)|*.exe'; if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; Remove-ItemProperty -Path $path -Name $dialog.FileName -ErrorAction SilentlyContinue; [System.Windows.Forms.MessageBox]::Show('The GPU preference has been removed for:' + [Environment]::NewLine + $dialog.FileName, 'EBOS Performance') ^| Out-Null }"
