@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -Command "$path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; $name = 'DirectXUserGlobalSettings'; $current = (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue).$name; if ($null -eq $current) { $current = '' }; if ($current -match 'VRROptimizeEnable=') { $current = [regex]::Replace($current, 'VRROptimizeEnable=\d+;', 'VRROptimizeEnable=1;') } else { $current += 'VRROptimizeEnable=1;' }; New-Item -Path $path -Force ^| Out-Null; Set-ItemProperty -Path $path -Name $name -Value $current"

echo Variable Refresh Rate has been enabled for the current user.
echo It is available only on compatible displays and graphics drivers.
pause
