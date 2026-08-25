@echo off
title Clear DirectX Shader Cache

echo Clearing the DirectX shader cache...
del /q /f /s "%localappdata%\D3DSCache\*" > nul 2>&1
del /q /f /s "%localappdata%\NVIDIA\DXCache\*" > nul 2>&1
del /q /f /s "%localappdata%\NVIDIA\GLCache\*" > nul 2>&1
del /q /f /s "%localappdata%\AMD\DxCache\*" > nul 2>&1
del /q /f /s "%localappdata%\AMD\GLCache\*" > nul 2>&1
del /q /f /s "%locallowappdata%\NVIDIA\PerDriverVersion\DXCache\*" > nul 2>&1

echo.
echo The DirectX shader cache has been cleared.
echo The shaders will be rebuilt automatically the next time you play.
echo Press any key to exit...
pause > nul
exit /b
