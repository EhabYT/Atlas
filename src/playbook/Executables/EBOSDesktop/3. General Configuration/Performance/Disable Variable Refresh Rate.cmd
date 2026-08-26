@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -Command "$path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; $name = 'DirectXUserGlobalSettings'; $current = (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue).$name; if ($null -eq $current) { $current = '' }; if ($current -match 'VRROptimizeEnable=') { $current = [regex]::Replace($current, 'VRROptimizeEnable=\d+;', 'VRROptimizeEnable=0;') } else { $current += 'VRROptimizeEnable=0;' }; New-Item -Path $path -Force ^| Out-Null; Set-ItemProperty -Path $path -Name $name -Value $current"

echo Variable Refresh Rate has been disabled for the current user.
pause
