@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -Command "$path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; $name = 'DirectXUserGlobalSettings'; $current = (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue).$name; if ($null -eq $current) { $current = '' }; if ($current -match 'SwapEffectUpgradeEnable=') { $current = [regex]::Replace($current, 'SwapEffectUpgradeEnable=\d+;', 'SwapEffectUpgradeEnable=0;') } else { $current += 'SwapEffectUpgradeEnable=0;' }; New-Item -Path $path -Force ^| Out-Null; Set-ItemProperty -Path $path -Name $name -Value $current"

echo Optimizations for windowed games has been disabled for the current user.
echo Restart any running games for the setting to take effect.
pause
