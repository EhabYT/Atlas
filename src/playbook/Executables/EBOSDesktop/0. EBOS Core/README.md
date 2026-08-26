# 0. EBOS Core

The EBOS Core folder is the control center of your EBOS installation.
Every tool here is a thin launcher over the Core PowerShell engine in
`%WINDIR%\EBOSModules\Core\` — no background processes, services or
scheduled tasks are created by EBOS Core.

| Launcher | What it does | CLI equivalent |
|---|---|---|
| `EBOS Dashboard.cmd` | Interactive menu for everything below | `EBOS-Dashboard.ps1` |
| `System Report.cmd` | Hardware + compatibility report | `EBOS-Detect.ps1 -WriteReport` |
| `Validate System Health.cmd` | `[PASS]/[FAIL]` validation of boot, Explorer, taskbar, network, audio, GPU, storage, updates, Defender, Bluetooth, USB, sleep, recovery and Liquid Glass | `EBOS-Validate.ps1` |
| `Create EBOS Backup.cmd` | Timestamped registry/services backup + system restore point | `EBOS-Backup.ps1` |
| `EBOS Rollback.cmd` | Lists backups / undoable change-sets / restore points | `EBOS-Rollback.ps1 -List` |
| `Configure Taskbar.cmd` | Alignment, size, multi-monitor, reset | `EBOS-Taskbar.ps1` |
| `Liquid Glass Quality.cmd` | Material quality tier (auto or manual) | `EBOS-Glass.ps1` |
| `Apply Profile.cmd` | Applies an EBOS profile | `EBOS-Profiles.ps1 -Apply <name>` |

## Change log & rollback

Every EBOS Core action is appended to
`%WINDIR%\EBOSModules\Other\ebos-change-log.txt`
(human readable) and `ebos-change-log.jsonl` (machine readable).

Registry changes made by Core scripts capture their **previous value**
first, so they can always be undone:

```powershell
# undo the last taskbar change
& $env:WINDIR\EBOSModules\Core\EBOS-Rollback.ps1 -UndoChangeSet taskbar
# undo the last profile application
& $env:WINDIR\EBOSModules\Core\EBOS-Profiles.ps1 -Undo
# restore the newest full backup
& $env:WINDIR\EBOSModules\Core\EBOS-Rollback.ps1 -Latest
```

See `docs/RECOVERY.md` in the repository for the full recovery model.
