# =====================================================================
#  EBOS Core — Rollback CLI
#  ---------------------------------------------------------------
#  Restores a previous EBOS backup, undoes the last captured change-set
#  (profile / taskbar / glass), or lists available recovery options.
#
#  Usage:
#    EBOS-Rollback.ps1 -List
#    EBOS-Rollback.ps1 -Latest                # restore newest backup
#    EBOS-Rollback.ps1 -Name <backupDirName>
#    EBOS-Rollback.ps1 -UndoChangeSet taskbar # undo last captured change-set
# =====================================================================
param([switch]$List, [switch]$Latest, [string]$Name, [string]$UndoChangeSet)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'EBOS-Core.ps1')
Assert-EBOSAdmin

if ($List) {
    $backups = Get-EBOSBackups
    Write-Output '=== EBOS Backups ==='
    if ($backups.Count -eq 0) { Write-Output '  (none)' }
    foreach ($b in $backups) { Write-Output ('  ' + $b.Name) }
    Write-Output ''
    Write-Output '=== Captured change-sets (undoable) ==='
    $sets = Get-ChildItem $script:EBOSOtherDir -Filter 'changeset-*.json' -ErrorAction SilentlyContinue
    if (!$sets -or $sets.Count -eq 0) { Write-Output '  (none)' }
    else { foreach ($s in $sets) { Write-Output ('  ' + $s.Name) } }
    Write-Output ''
    Write-Output '=== System restore points ==='
    try {
        $rps = Get-ComputerRestorePoint -ErrorAction Stop
        foreach ($rp in ($rps | Select-Object -Last 10)) { Write-Output ('  ' + $rp.CreationTime + '  ' + $rp.Description) }
    } catch { Write-Output '  (unavailable or none)' }
    exit 0
}

if ($UndoChangeSet) {
    $path = Join-Path $script:EBOSOtherDir ('changeset-{0}.json' -f $UndoChangeSet)
    if (!(Test-Path $path)) { Write-Error "No captured change-set for '$UndoChangeSet'."; exit 1 }
    $set = Load-EBOSChangeSet -Path $path
    Undo-EBOSChangeSet -ChangeSet $set
    Restart-EBOSExplorer | Out-Null
    Write-Output "Reverted change-set '$UndoChangeSet'."
    exit 0
}

if ($Latest -or $Name) {
    $target = $null
    if ($Latest) { $target = (Get-EBOSBackups | Select-Object -First 1) }
    else { $target = Get-EBOSBackups | Where-Object Name -eq $Name }
    if (!$target) { Write-Error 'Backup not found. Use -List to see available backups.'; exit 1 }
    Restore-EBOSBackup -Path $target.FullName
    Write-Output 'EBOS backup restored. A reboot is recommended for services/drivers changes.'
    exit 0
}

Write-Output 'EBOS Rollback — specify -List, -Latest, -Name <backup> or -UndoChangeSet <label>.'
exit 0
