# =====================================================================
#  EBOS Core — Backup CLI
#  ---------------------------------------------------------------
#  Creates EBOS backups (registry + scheduled-task states) and an
#  optional system restore point.
#
#  Usage:
#    EBOS-Backup.ps1                      # manual backup
#    EBOS-Backup.ps1 -PreInstall          # playbook pre-flight backup
#    EBOS-Backup.ps1 -List                # list available backups
# =====================================================================
param([switch]$PreInstall, [switch]$List, [string]$Label = 'manual')

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'EBOS-Core.ps1')
Assert-EBOSAdmin

if ($List) {
    $backups = Get-EBOSBackups
    if ($backups.Count -eq 0) { Write-Output 'No EBOS backups found.'; exit 0 }
    Write-Output 'EBOS backups (newest first):'
    foreach ($b in $backups) { Write-Output ('  ' + $b.Name) }
    exit 0
}

if ($PreInstall) { $Label = 'pre-install' }
$dest = New-EBOSBackup -Label $Label -RestorePoint
Write-Output ("EBOS backup created: " + $dest)
exit 0
