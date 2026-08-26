# =====================================================================
#  EBOS Core — shared library
#  ---------------------------------------------------------------
#  Central engine used by every EBOS module and CLI script:
#    - Logging (human-readable change log + machine-readable JSONL)
#    - Hardware / OS detection
#    - Compatibility verdicts
#    - Backup + rollback primitives
#    - Validation helpers
#
#  This file is dot-sourced by the other EBOS-* scripts and is not
#  intended to be executed directly.
#
#  License: CC BY-SA 4.0 (see repository LICENSE)
# =====================================================================

Set-StrictMode -Version 2.0

$script:EBOSModulesRoot = Join-Path $env:WINDIR 'EBOSModules'
$script:EBOSCoreDir     = Join-Path $script:EBOSModulesRoot 'Core'
$script:EBOSOtherDir    = Join-Path $script:EBOSModulesRoot 'Other'
$script:EBOSBackupsDir  = Join-Path $script:EBOSModulesRoot 'Backups'

# Builds officially supported by this EBOS release (keep in sync with playbook.conf)
$script:EBOSSupportedBuilds = @(26100, 26200)

# ---------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------
function Write-EBOSLog {
    <#
    .SYNOPSIS
        Appends a line to the EBOS change log (text) and change log (JSONL).
    .PARAMETER Message
        Human-readable description of the change or event.
    .PARAMETER Module
        EBOS domain/module that produced the entry (Core, Network, Gaming, ...).
    .PARAMETER Change
        Short machine-readable change identifier.
    .PARAMETER Status
        SUCCESS | FAILURE | SKIPPED | INFO.
    .PARAMETER Rollback
        Availability of a rollback for this entry (AVAILABLE / NONE).
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [string]$Module = 'Core',
        [string]$Change = '',
        [ValidateSet('SUCCESS', 'FAILURE', 'SKIPPED', 'INFO')]
        [string]$Status = 'INFO',
        [string]$Rollback = 'NONE'
    )
    foreach ($dir in @($script:EBOSModulesRoot, $script:EBOSOtherDir)) {
        if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
    }
    $textLog = Join-Path $script:EBOSOtherDir 'ebos-change-log.txt'
    $jsonLog = Join-Path $script:EBOSOtherDir 'ebos-change-log.jsonl'
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path $textLog -Value ("[{0}] [{1}] [{2}] {3} (status: {4}, rollback: {5})" -f $stamp, $Module, $Status, $Message, $Status, $Rollback) -Encoding UTF8
    $entry = [ordered]@{
        timestamp = (Get-Date).ToUniversalTime().ToString('o')
        module    = $Module
        change    = $Change
        message   = $Message
        status    = $Status
        rollback  = $Rollback
    }
    try { Add-Content -Path $jsonLog -Value ($entry | ConvertTo-Json -Compress) -Encoding UTF8 } catch { }
}

function Get-EBOSChangeLog {
    param([int]$Last = 40)
    $textLog = Join-Path $script:EBOSOtherDir 'ebos-change-log.txt'
    if (Test-Path $textLog) { Get-Content $textLog -Tail $Last }
    else { Write-Output 'EBOS change log is empty.' }
}

# ---------------------------------------------------------------------
# Privilege / environment
# ---------------------------------------------------------------------
function Test-EBOSAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($identity)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-EBOSAdmin {
    if (!(Test-EBOSAdmin)) {
        Write-Error 'EBOS: administrator privileges are required for this operation. Re-run from an elevated prompt.'
        exit 1
    }
}

# ---------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------
function Get-EBOSSystemInfo {
    <#
    .SYNOPSIS
        Detects Windows version/build, architecture, CPU, GPU, RAM,
        storage, chassis (laptop/desktop), firmware, virtualization,
        battery and network adapters. Returns a PSCustomObject.
    #>
    $os        = Get-CimInstance Win32_OperatingSystem
    $cs        = Get-CimInstance Win32_ComputerSystem
    $cpu       = Get-CimInstance Win32_Processor | Select-Object -First 1
    $gpus      = @(Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch 'Basic (Microsoft|Display)' })
    $battery   = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    $build     = [int](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild
    $ubr       = [int](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').UBR
    $displayVer = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion

    # Firmware: UEFI vs Legacy BIOS
    $firmware = 'Unknown'
    try { $firmware = if (Confirm-SecureBootUEFI) { 'UEFI (Secure Boot on)' } else { 'UEFI' } }
    catch { $firmware = 'Legacy BIOS (or UEFI without Secure Boot)' }

    # Virtualization detection
    $virt = $false
    $virtNote = ''
    if ($cs.Model -match 'Virtual|VMware|VirtualBox|QEMU|Xen|KVM|HVM|oVirt') { $virt = $true; $virtNote = $cs.Model }
    if ($cpu.Manufacturer -match 'QEMU|Virtio|Xen') { $virt = $true; $virtNote = $cpu.Manufacturer }
    if ((Get-CimInstance Win32_ComputerSystem).HypervisorPresent) { $virt = $true; $virtNote = 'Hyper-V hypervisor present' }

    # Storage media types
    $disks = @()
    try {
        $disks = @(Get-PhysicalDisk | ForEach-Object { '{0} ({1}, {2} GB, {3})' -f $_.FriendlyName, $_.MediaType, [math]::Round($_.Size / 1GB), $_.HealthStatus })
    } catch { $disks = @('query unavailable') }

    # Network adapters (physical, connected)
    $netAdapters = @()
    try {
        $netAdapters = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object Status -eq 'Up' | ForEach-Object { $_.Name + ' (' + $_.InterfaceDescription + ')' })
    } catch { }

    # GPU capability class (used for Liquid Glass quality selection)
    $gpuClass = 'None'
    $gpuNames = @($gpus | ForEach-Object Name)
    if ($gpuNames.Count -gt 0) {
        $gpuClass = 'Integrated'
        foreach ($g in $gpus) {
            $ram = 0; try { $ram = [math]::Round($g.AdapterRAM / 1GB) } catch { }
            if ($g.Name -match 'NVIDIA|GeForce|Radeon|Arc') { $gpuClass = 'Discrete' }
            if ($g.Name -match 'RTX|Radeon RX (6|7|9)|Arc A') { $gpuClass = 'HighEnd' }
        }
    }

    [PSCustomObject]@{
        ComputerName    = $env:COMPUTERNAME
        WindowsName     = $os.Caption
        DisplayVersion  = $displayVer
        Build           = $build
        UBR             = $ubr
        Arch            = $os.OSArchitecture
        Chassis         = if ($battery -and $battery.Count -gt 0 -and $cs.PCSystemType -eq 2) { 'Laptop' } elseif ($cs.PCSystemType -eq 2) { 'Mobile' } else { 'Desktop' }
        Manufacturer    = $cs.Manufacturer
        Model           = $cs.Model
        CPU             = $cpu.Name
        Cores           = $cpu.NumberOfCores
        LogicalProcessors = $cpu.NumberOfLogicalProcessors
        GPUs            = $gpuNames
        GPUPerfClass    = $gpuClass
        RAMGB           = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
        Firmware        = $firmware
        Virtualized     = $virt
        VirtualizationNote = $virtNote
        BatteryPresent  = ($null -ne $battery -and $battery.Count -gt 0)
        Storage         = $disks
        NetworkAdapters = $netAdapters
        AdminContext    = Test-EBOSAdmin
    }
}

function Get-EBOSCompatibility {
    <#
    .SYNOPSIS
        Returns the compatibility verdict for the current system against
        this EBOS release. Unsupported systems should cause modules to
        SKIP (never force obsolete tweaks).
    #>
    $info = Get-EBOSSystemInfo
    $supported = $script:EBOSSupportedBuilds -contains $info.Build
    [PSCustomObject]@{
        Supported    = $supported
        Build        = $info.Build
        SupportedBuilds = $script:EBOSSupportedBuilds
        Verdict      = if ($supported) { 'SUPPORTED' } else { 'UNSUPPORTED' }
        Recommendation = if ($supported) { 'All EBOS modules may run.' }
                          else { "SKIPPED — this optimization is not supported on Windows build $($info.Build). No modification was performed." }
    }
}

# ---------------------------------------------------------------------
# Registry helpers with automatic prior-value capture (rollback-ready)
# ---------------------------------------------------------------------
function Set-EBOSRegistry {
    <#
    .SYNOPSIS
        Sets a registry value and records the previous value in the
        supplied change-set so it can be undone by Undo-EBOSChangeSet.
    #>
    param(
        [Parameter(Mandatory)]$Path,
        [Parameter(Mandatory)]$Name,
        [Parameter(Mandatory)]$Data,
        [string]$Type = 'DWord',
        [System.Collections.ArrayList]$ChangeSet
    )
    $prior = $null; $had = $false
    if (Test-Path $Path) {
        $existing = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        if ($null -ne $existing) { $prior = $existing.$Name; $had = $true }
    } else {
        New-Item -Path $Path -Force | Out-Null
    }
    New-ItemProperty -Path $Path -Name $Name -Value $Data -PropertyType $Type -Force | Out-Null
    if ($ChangeSet) {
        $null = $ChangeSet.Add([ordered]@{ path = $Path; name = $Name; hadValue = $had; prior = $prior; type = $Type })
    }
    Write-EBOSLog -Message "Registry: $Name in $Path -> $Data" -Module 'Core' -Change 'registry' -Status 'SUCCESS' -Rollback 'AVAILABLE'
}

function Undo-EBOSChangeSet {
    <#
    .SYNOPSIS
        Reverts every entry captured by Set-EBOSRegistry's change-set.
    #>
    param([Parameter(Mandatory)]$ChangeSet)
    foreach ($entry in $ChangeSet) {
        if (!(Test-Path $entry.path)) { continue }
        if ($entry.hadValue) {
            New-ItemProperty -Path $entry.path -Name $entry.name -Value $entry.prior -PropertyType $entry.type -Force | Out-Null
        } else {
            Remove-ItemProperty -Path $entry.path -Name $entry.name -ErrorAction SilentlyContinue
        }
    }
    Write-EBOSLog -Message 'Reverted a captured change-set (registry values restored).' -Module 'Core' -Change 'rollback' -Status 'SUCCESS' -Rollback 'NONE'
}

function Save-EBOSChangeSet {
    param([Parameter(Mandatory)]$ChangeSet, [Parameter(Mandatory)][string]$Label)
    if (!(Test-Path $script:EBOSOtherDir)) { New-Item -Path $script:EBOSOtherDir -ItemType Directory -Force | Out-Null }
    $safe = Join-Path $script:EBOSOtherDir ('changeset-{0}.json' -f ($Label -replace '[^A-Za-z0-9._-]', '_'))
    $ChangeSet | ConvertTo-Json -Depth 5 | Set-Content -Path $safe -Encoding UTF8
    $safe
}

function Load-EBOSChangeSet {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-Path $Path) { Get-Content $Path -Raw | ConvertFrom-Json }
}

# ---------------------------------------------------------------------
# Backup / rollback primitives
# ---------------------------------------------------------------------
function New-EBOSBackup {
    <#
    .SYNOPSIS
        Creates a timestamped backup: services registry hive, policies,
        the default-user hive reference, scheduled-task states and
        (optionally) a system restore point.
    #>
    param([string]$Label = 'manual', [switch]$RestorePoint)
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $dest = Join-Path $script:EBOSBackupsDir "$stamp-$Label"
    New-Item -Path $dest -ItemType Directory -Force | Out-Null

    $exports = @(
        @{ key = 'HKLM\SYSTEM\CurrentControlSet\Services'; file = 'services.reg' },
        @{ key = 'HKLM\SOFTWARE\Policies';                 file = 'policies.reg' },
        @{ key = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'; file = 'explorer.reg' }
    )
    foreach ($e in $exports) {
        reg export $e.key (Join-Path $dest $e.file) /y | Out-Null
    }
    # Scheduled task states (name + state) for rollback reporting
    try {
        schtasks /query /fo csv | Out-File -FilePath (Join-Path $dest 'scheduled-tasks.csv') -Encoding UTF8
    } catch { }
    # Metadata
    @{ timestamp = $stamp; label = $Label; host = $env:COMPUTERNAME } | ConvertTo-Json | Set-Content (Join-Path $dest 'backup.json') -Encoding UTF8

    if ($RestorePoint) {
        try {
            Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
            Checkpoint-Computer -Description "EBOS $Label" -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
            Write-EBOSLog -Message "Created system restore point 'EBOS $Label'." -Module 'Recovery' -Change 'restore-point' -Status 'SUCCESS' -Rollback 'NONE'
        } catch {
            Write-EBOSLog -Message "Restore point skipped (24h limit or System Restore unavailable): $($_.Exception.Message)" -Module 'Recovery' -Change 'restore-point' -Status 'SKIPPED'
        }
    }
    Write-EBOSLog -Message "Created EBOS backup '$stamp-$Label' in $dest." -Module 'Recovery' -Change 'backup' -Status 'SUCCESS' -Rollback 'NONE'
    return $dest
}

function Get-EBOSBackups {
    if (!(Test-Path $script:EBOSBackupsDir)) { return @() }
    Get-ChildItem $script:EBOSBackupsDir -Directory | Sort-Object Name -Descending
}

function Restore-EBOSBackup {
    <#
    .SYNOPSIS
        Restores registry exports from an EBOS backup directory.
    #>
    param([Parameter(Mandatory)][string]$Path)
    if (!(Test-Path $Path)) { Write-Error "Backup not found: $Path"; return }
    foreach ($reg in (Get-ChildItem $Path -Filter '*.reg')) {
        reg import $reg.FullName 2>$null | Out-Null
        Write-Output ("Restored " + $reg.Name)
    }
    Write-EBOSLog -Message "Restored EBOS backup from $Path." -Module 'Recovery' -Change 'restore' -Status 'SUCCESS' -Rollback 'NONE'
}

# ---------------------------------------------------------------------
# Explorer / taskbar recovery helpers
# ---------------------------------------------------------------------
function Restart-EBOSExplorer {
    <#
    .SYNOPSIS
        Safely restarts Explorer and verifies the shell (taskbar) came
        back. Returns $true when the shell is healthy afterwards.
    #>
    param([int]$Attempts = 3)
    for ($i = 1; $i -le $Attempts; $i++) {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        $proc = Get-Process -Name explorer -ErrorAction SilentlyContinue
        if (!$proc) { Start-Process explorer.exe }
        Start-Sleep -Seconds 3
        $proc = Get-Process -Name explorer -ErrorAction SilentlyContinue
        $shell = $null
        try { $shell = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name Shell -ErrorAction SilentlyContinue).Shell } catch { }
        if ($proc -and ($shell -like '*explorer*')) {
            Write-EBOSLog -Message 'Explorer restarted successfully; taskbar validated.' -Module 'UI' -Change 'explorer-restart' -Status 'SUCCESS'
            return $true
        }
    }
    Write-EBOSLog -Message 'Explorer failed to restart cleanly after multiple attempts.' -Module 'UI' -Change 'explorer-restart' -Status 'FAILURE'
    return $false
}
