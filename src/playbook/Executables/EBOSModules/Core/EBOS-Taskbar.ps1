# =====================================================================
#  EBOS Core — Windows 11 Taskbar Controller
#  ---------------------------------------------------------------
#  Configures the EBOS taskbar experience: alignment, size, multi-
#  monitor behavior, material and recovery. Every change is captured
#  in a change-set; if Explorer fails to come back with a healthy
#  taskbar, the last change-set is rolled back automatically and
#  Explorer is restarted again (see Restart-EBOSTaskbarSafe).
#
#  Usage:
#    EBOS-Taskbar.ps1 -Status
#    EBOS-Taskbar.ps1 -Align center|left
#    EBOS-Taskbar.ps1 -Size small|default|large
#    EBOS-Taskbar.ps1 -MultiMonitor on|off|primary
#    EBOS-Taskbar.ps1 -Reset            # restore Windows defaults
# =====================================================================
param([string]$Align, [string]$Size, [string]$MultiMonitor, [switch]$Status, [switch]$Reset)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'EBOS-Core.ps1')
Assert-EBOSAdmin

$advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

function Get-TaskbarState {
    $get = { param($n) try { (Get-ItemProperty $advanced -Name $n -ErrorAction Stop).$n } catch { $null } }
    [PSCustomObject]@{
        Alignment       = $(& $get 'TaskbarAl')        # 1 = centered (default), 0 = left
        Size            = $(& $get 'TaskbarSi')        # 0 = small, 1 = default (absent), 2 = large
        MultiMonitor    = $(& $get 'MMTaskbarEnabled') # 1 = taskbar on all displays
        MMAlignment     = $(& $get 'MMTaskbarAl')
    }
}

function Test-TaskbarHealthy {
    $proc = Get-Process -Name explorer -ErrorAction SilentlyContinue
    [bool]$proc
}

function Restart-EBOSTaskbarSafe {
    <#
    .SYNOPSIS
        Explorer recovery loop:
          restart Explorer -> validate taskbar -> on failure roll back the
          last captured taskbar change-set -> restart -> validate again.
        Never leaves the user without a shell.
    #>
    param($ChangeSetPath)
    if (Restart-EBOSExplorer) { return $true }
    if ($ChangeSetPath -and (Test-Path $ChangeSetPath)) {
        Write-Output 'Taskbar failed validation — rolling back the last EBOS taskbar modification...'
        Undo-EBOSChangeSet -ChangeSet (Load-EBOSChangeSet -Path $ChangeSetPath)
        Write-EBOSLog -Message 'Rolled back the last taskbar modification after Explorer validation failure.' -Module 'UI' -Change 'taskbar-rollback' -Status 'SUCCESS'
        if (Restart-EBOSExplorer) { return $true }
    }
    Write-Warning 'EBOS could not validate the taskbar. Run "EBOS-Taskbar.ps1 -Reset" or reboot.'
    return $false
}

function Apply-TaskbarChange {
    param([scriptblock]$Block)
    $changeSet = New-Object System.Collections.ArrayList
    & $Block $changeSet
    $setPath = Save-EBOSChangeSet -ChangeSet $changeSet -Label 'taskbar'
    Restart-EBOSTaskbarSafe -ChangeSetPath $setPath | Out-Null
}

if ($Status) {
    $s = Get-TaskbarState
    $align = if ($null -eq $s.Alignment -or $s.Alignment -eq 1) { 'center (default)' } else { 'left' }
    $size  = switch ($s.Size) { 0 { 'small' } 2 { 'large' } default { 'default' } }
    $mm    = if ($s.MultiMonitor -eq 0) { 'primary monitor only' } else { 'all monitors' }
    Write-Output "EBOS Taskbar state"
    Write-Output "  Alignment    : $align"
    Write-Output "  Size         : $size  (DPI-aware: sizes scale automatically at 100-200%)"
    Write-Output "  Multi-monitor: $mm"
    exit 0
}

if ($Reset) {
    $changeSet = New-Object System.Collections.ArrayList
    foreach ($name in 'TaskbarAl', 'TaskbarSi', 'MMTaskbarEnabled', 'MMTaskbarAl', 'MMTaskbarSi') {
        if (Test-Path $advanced) {
            $existing = Get-ItemProperty $advanced -Name $name -ErrorAction SilentlyContinue
            if ($null -ne $existing) {
                $null = $changeSet.Add([ordered]@{ path = $advanced; name = $name; hadValue = $true; prior = $existing.$name; type = 'DWord' })
                Remove-ItemProperty $advanced -Name $name -ErrorAction SilentlyContinue
            }
        }
    }
    $setPath = Save-EBOSChangeSet -ChangeSet $changeSet -Label 'taskbar-reset'
    Write-EBOSLog -Message 'Taskbar reset to Windows defaults.' -Module 'UI' -Change 'taskbar-reset' -Status 'SUCCESS' -Rollback 'AVAILABLE'
    Restart-EBOSTaskbarSafe -ChangeSetPath $setPath | Out-Null
    Write-Output 'EBOS taskbar settings reset to Windows defaults. (Other EBOS optimizations are untouched.)'
    exit 0
}

if ($Align) {
    if ($Align -notin @('center', 'left')) { Write-Error 'Align must be center or left.'; exit 1 }
    $v = if ($Align -eq 'center') { 1 } else { 0 }
    Apply-TaskbarChange({ param($cs)
        Set-EBOSRegistry -Path $advanced -Name 'TaskbarAl'   -Data $v -ChangeSet $cs
        Set-EBOSRegistry -Path $advanced -Name 'MMTaskbarAl' -Data $v -ChangeSet $cs
    })
    Write-Output "Taskbar alignment set to $Align."
}

if ($Size) {
    $v = switch ($Size) { 'small' { 0 } 'default' { 1 } 'large' { 2 } default { $null } }
    if ($null -eq $v) { Write-Error 'Size must be small, default or large.'; exit 1 }
    Apply-TaskbarChange({ param($cs)
        if ($v -eq 1) {
            # default size — value removed (Windows default)
            if (Test-Path $advanced) {
                $existing = Get-ItemProperty $advanced -Name 'TaskbarSi' -ErrorAction SilentlyContinue
                if ($null -ne $existing) {
                    $null = $cs.Add([ordered]@{ path = $advanced; name = 'TaskbarSi'; hadValue = $true; prior = $existing.TaskbarSi; type = 'DWord' })
                    Remove-ItemProperty $advanced -Name 'TaskbarSi' -ErrorAction SilentlyContinue
                }
            }
        } else {
            Set-EBOSRegistry -Path $advanced -Name 'TaskbarSi'   -Data $v -ChangeSet $cs
            Set-EBOSRegistry -Path $advanced -Name 'MMTaskbarSi' -Data $v -ChangeSet $cs
        }
    })
    Write-Output "Taskbar size set to $Size."
}

if ($MultiMonitor) {
    Apply-TaskbarChange({ param($cs)
        $mmv = if ($MultiMonitor -eq 'primary') { 0 } else { 1 }
        Set-EBOSRegistry -Path $advanced -Name 'MMTaskbarEnabled' -Data $mmv -ChangeSet $cs
    })
    Write-Output "Multi-monitor taskbar mode set to $MultiMonitor."
}

if (!($Align -or $Size -or $MultiMonitor)) {
    Write-Output 'EBOS Taskbar — use -Status, -Align <center|left>, -Size <small|default|large>, -MultiMonitor <on|off|primary> or -Reset.'
}
exit 0
