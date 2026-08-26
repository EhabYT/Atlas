@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -Command "$path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; $name = 'DirectXUserGlobalSettings'; $current = (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue).$name; if ($null -eq $current) { $current = '' }; if ($current -match 'AutoHDREnable=') { $current = [regex]::Replace($current, 'AutoHDREnable=\d+;', 'AutoHDREnable=1;') } else { $current += 'AutoHDREnable=1;' }; New-Item -Path $path -Force ^| Out-Null; Set-ItemProperty -Path $path -Name $name -Value $current"

echo Auto HDR has been enabled for the current user.
echo It is available only on compatible HDR displays and games.
pause
