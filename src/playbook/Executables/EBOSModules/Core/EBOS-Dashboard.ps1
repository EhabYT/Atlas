# =====================================================================
#  EBOS Core — Dashboard
#  ---------------------------------------------------------------
#  Interactive hub for the EBOS Desktop ("0. EBOS Core" folder).
#  Everything reachable from here is also available as a CLI script.
# =====================================================================
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'EBOS-Core.ps1')

function Pause-Menu { Write-Output ''; Read-Host 'Press Enter to return to the menu' | Out-Null }

function Show-Menu {
    Clear-Host
    Write-Output @'
======================================================
   E B O S   --   D A S H B O A R D
   Unified performance - privacy - security - UX
======================================================
  System
    1) System report (hardware + compatibility)
    2) Validate system health
    3) View EBOS change log
  Profiles
    4) List profiles
    5) Apply a profile
  Appearance
    6) Taskbar status
    7) Configure taskbar (alignment / size / multi-monitor)
    8) Liquid Glass status
    9) Set Liquid Glass quality
  Recovery
   10) Create EBOS backup
   11) Rollback (backups / change-sets / restore points)
   12) Reset taskbar to Windows defaults
    0) Exit
======================================================
'@
}

$elevated = Test-EBOSAdmin
if (!$elevated) {
    Write-Warning 'Not elevated — system-changing actions will fail. Relaunch as administrator.'
}

loop: while ($true) {
    Show-Menu
    $choice = Read-Host 'Select'
    switch ($choice) {
        '1' { & (Join-Path $here 'EBOS-Detect.ps1') -WriteReport; Pause-Menu }
        '2' { & (Join-Path $here 'EBOS-Validate.ps1'); Pause-Menu }
        '3' { Get-EBOSChangeLog -Last 60; Pause-Menu }
        '4' { & (Join-Path $here 'EBOS-Profiles.ps1') -List; Pause-Menu }
        '5' {
            & (Join-Path $here 'EBOS-Profiles.ps1') -List
            $p = Read-Host 'Profile name'
            if ($p) { & (Join-Path $here 'EBOS-Profiles.ps1') -Apply $p }
            Pause-Menu
        }
        '6' { & (Join-Path $here 'EBOS-Taskbar.ps1') -Status; Pause-Menu }
        '7' {
            & (Join-Path $here 'EBOS-Taskbar.ps1') -Status
            Write-Output 'Examples: -Align center|left  -Size small|default|large  -MultiMonitor on|off|primary'
            $a = Read-Host 'Alignment (center/left, blank to skip)'
            $s = Read-Host 'Size (small/default/large, blank to skip)'
            $m = Read-Host 'Multi-monitor (on/off/primary, blank to skip)'
            if ($a) { & (Join-Path $here 'EBOS-Taskbar.ps1') -Align $a }
            if ($s) { & (Join-Path $here 'EBOS-Taskbar.ps1') -Size $s }
            if ($m) { & (Join-Path $here 'EBOS-Taskbar.ps1') -MultiMonitor $m }
            Pause-Menu
        }
        '8' { & (Join-Path $here 'EBOS-Glass.ps1') -Status; Pause-Menu }
        '9' {
            & (Join-Path $here 'EBOS-Glass.ps1') -Status
            $q = Read-Host 'Quality (Ultra/High/Balanced/Performance/Compatibility, blank = Auto)'
            if ($q) { & (Join-Path $here 'EBOS-Glass.ps1') -Quality $q }
            else { & (Join-Path $here 'EBOS-Glass.ps1') -Auto }
            Pause-Menu
        }
        '10' { & (Join-Path $here 'EBOS-Backup.ps1'); Pause-Menu }
        '11' { & (Join-Path $here 'EBOS-Rollback.ps1') -List; Pause-Menu }
        '12' { & (Join-Path $here 'EBOS-Taskbar.ps1') -Reset; Pause-Menu }
        '0' { break loop }
        default { }
    }
}
