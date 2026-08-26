# =====================================================================
#  EBOS Core — Liquid Glass Controller
#  ---------------------------------------------------------------
#  Selects and applies the EBOS Liquid Glass quality tier.
#
#  Quality tiers (docs/design-system/MATERIALS.md):
#    Ultra          full material stack: refraction emulation,
#                   blur, saturation, specular highlight, rim
#    High           blur + highlight + rim (no refraction)
#    Balanced       blur + rim (recommended default)
#    Performance    translucency only, animations off
#    Compatibility  opaque fallback (reduced transparency/motion,
#                   weak GPU, or battery saver)
#
#  Fallback chain: Refraction -> Blur+Highlight -> Translucency -> Opaque
#
#  Usage:
#    EBOS-Glass.ps1 -Status
#    EBOS-Glass.ps1 -Auto [-Quiet]     # hardware/battery/accessibility aware
#    EBOS-Glass.ps1 -Quality High [-Quiet]
# =====================================================================
param([string]$Quality, [switch]$Auto, [switch]$Status, [switch]$Quiet)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'EBOS-Core.ps1')

$personal = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$dwmKey   = 'HKCU:\Software\Microsoft\Windows\DWM'
$glassReg = 'HKLM:\SOFTWARE\EBOS\Glass'
$tiers = @('Ultra', 'High', 'Balanced', 'Performance', 'Compatibility')

function Get-GlassState {
    $t = 0
    try { $t = [int](Get-ItemProperty $personal -Name EnableTransparency -ErrorAction Stop).EnableTransparency } catch { }
    $q = $null
    try { $q = (Get-ItemProperty $glassReg -Name Quality -ErrorAction Stop).Quality } catch { }
    [PSCustomObject]@{ Quality = $q; TransparencyEnabled = ($t -eq 1) }
}

function Set-GlassQuality {
    param([Parameter(Mandatory)][ValidateSet('Ultra', 'High', 'Balanced', 'Performance', 'Compatibility')][string]$Tier)

    $changeSet = New-Object System.Collections.ArrayList
    switch ($Tier) {
        'Ultra' {
            Set-EBOSRegistry -Path $personal -Name 'EnableTransparency' -Data 1 -ChangeSet $changeSet
            Set-EBOSRegistry -Path $advanced -Name 'TaskbarAnimations'  -Data 1 -ChangeSet $changeSet
            Set-EBOSRegistry -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name 'MinAnimate' -Data 1 -ChangeSet $changeSet
            Set-EBOSRegistry -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Data 2 -ChangeSet $changeSet
        }
        'High' {
            Set-EBOSRegistry -Path $personal -Name 'EnableTransparency' -Data 1 -ChangeSet $changeSet
            Set-EBOSRegistry -Path $advanced -Name 'TaskbarAnimations'  -Data 1 -ChangeSet $changeSet
            Set-EBOSRegistry -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Data 2 -ChangeSet $changeSet
        }
        'Balanced' {
            Set-EBOSRegistry -Path $personal -Name 'EnableTransparency' -Data 1 -ChangeSet $changeSet
            Set-EBOSRegistry -Path $advanced -Name 'TaskbarAnimations'  -Data 1 -ChangeSet $changeSet
            Set-EBOSRegistry -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Data 0 -ChangeSet $changeSet
        }
        'Performance' {
            Set-EBOSRegistry -Path $personal -Name 'EnableTransparency' -Data 1 -ChangeSet $changeSet
            Set-EBOSRegistry -Path $advanced -Name 'TaskbarAnimations'  -Data 0 -ChangeSet $changeSet
            Set-EBOSRegistry -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Data 1 -ChangeSet $changeSet
        }
        'Compatibility' {
            # Opaque fallback — respects reduced transparency / reduced motion
            Set-EBOSRegistry -Path $personal -Name 'EnableTransparency' -Data 0 -ChangeSet $changeSet
            Set-EBOSRegistry -Path $advanced -Name 'TaskbarAnimations'  -Data 0 -ChangeSet $changeSet
            Set-EBOSRegistry -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name 'MinAnimate' -Data 0 -ChangeSet $changeSet
            Set-EBOSRegistry -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Data 1 -ChangeSet $changeSet
        }
    }
    $null = Save-EBOSChangeSet -ChangeSet $changeSet -Label 'glass'
    New-Item -Path $glassReg -Force | Out-Null
    New-ItemProperty -Path $glassReg -Name 'Quality' -Value $Tier -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $glassReg -Name 'Applied' -Value (Get-Date).ToString('o') -PropertyType String -Force | Out-Null
    Write-EBOSLog -Message "Liquid Glass quality set to '$Tier'." -Module 'UI' -Change 'glass-quality' -Status 'SUCCESS' -Rollback 'AVAILABLE'
}

function Get-RecommendedTier {
    # ---------------- accessibility contract (always wins) ----------------
    $reducedTransparency = $false
    try { if ((Get-ItemProperty $personal -Name EnableTransparency -ErrorAction Stop).EnableTransparency -eq 0) { $reducedTransparency = $true } } catch { }
    # reduced motion: MinAnimate = 0 signals "show animations off"
    $reducedMotion = $false
    try { if ((Get-ItemProperty 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name MinAnimate -ErrorAction Stop).MinAnimate -eq 0) { $reducedMotion = $true } } catch { }

    if ($reducedTransparency -or $reducedMotion) { return 'Compatibility' }

    # ---------------- battery-aware ----------------
    $batterySaver = $false
    try {
        $bat = Get-CimInstance -ClassName Win32_Battery -ErrorAction Stop
        if ($bat -and $bat.BatteryStatus -eq 1 -and $bat.EstimatedChargeRemaining -lt 25) { $batterySaver = $true }
    } catch { }

    # ---------------- GPU-aware ----------------
    $gpuClass = 'Integrated'
    try {
        $info = Get-EBOSSystemInfo
        $gpuClass = $info.GPUPerfClass
    } catch { }

    if ($batterySaver) { return 'Performance' }
    switch ($gpuClass) {
        'HighEnd'    { if (!(Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue)) { 'Ultra' } else { 'High' } }
        'Discrete'   { 'High' }
        'Integrated' { 'Balanced' }
        'None'       { 'Compatibility' }
        default      { 'Balanced' }
    }
}

if ($Status) {
    $s = Get-GlassState
    Write-Output ("Liquid Glass quality : " + $(if ($s.Quality) { $s.Quality } else { '(not set)' }))
    Write-Output ("Transparency enabled : " + $s.TransparencyEnabled)
    Write-Output ("Recommended          : " + (Get-RecommendedTier))
    Write-Output 'Tiers: Ultra, High, Balanced, Performance, Compatibility'
    exit 0
}

if ($Auto) {
    $tier = Get-RecommendedTier
    Set-GlassQuality -Tier $tier
    if (!$Quiet) { Write-Output ("Liquid Glass quality automatically set to '$tier' (hardware, battery and accessibility aware).") }
    exit 0
}

if ($Quality) {
    if ($tiers -notcontains $Quality) { Write-Error ("Unknown quality '$Quality'. Valid: " + ($tiers -join ', ')); exit 1 }
    Set-GlassQuality -Tier $Quality
    if (!$Quiet) { Write-Output ("Liquid Glass quality set to '$Quality'.") }
    exit 0
}

Write-Output 'EBOS Liquid Glass — use -Status, -Auto or -Quality <Ultra|High|Balanced|Performance|Compatibility>.'
exit 0
