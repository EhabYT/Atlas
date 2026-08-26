<# :
@echo off &pushd "%~dp0"
@set batch_args=%*
@set script_path=%~f0
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (cat -Raw '%~f0')"
@exit /b %ERRORLEVEL%
: #>

$scriptPath = "$env:SystemRoot\Web\Wallpaper\EBOS\WALLPAPER.ps1"
& $scriptPath -Mode Desktop -ImagePath "$env:SystemRoot\Web\Wallpaper\EBOS\v2\desktop.jpg"
& $scriptPath -Mode LockScreen -ImagePath "$env:SystemRoot\Web\Wallpaper\EBOS\v2\lockscreen.jpg"

# Not an ideal place
# RARE Case, but on W10, when legacy Mail app is uninstalled, Outlook for Windows gets installed automatically
Get-AppxPackage Microsoft.OutlookForWindows* | Remove-AppxPackage