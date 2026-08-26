@echo off
setlocal

echo This removes the current user's DirectX shader cache.
echo Games may stutter temporarily while rebuilding their shader cache.
choice /c YN /m "Continue"
if errorlevel 2 exit /b

powershell -NoProfile -ExecutionPolicy Bypass -Command "$cache = Join-Path $env:LOCALAPPDATA 'D3DSCache'; if (Test-Path $cache) { Get-ChildItem -LiteralPath $cache -Force -ErrorAction SilentlyContinue ^| Remove-Item -Force -Recurse -ErrorAction SilentlyContinue }"

echo DirectX shader-cache files have been cleared.
pause
