# =====================================================================
#  EBOS Core — Profile Engine
#  ---------------------------------------------------------------
#  Applies EBOS profiles. A profile configures optimization AND
#  appearance settings together; every registry write is captured in
#  a change-set so a profile application can be undone.
#
#  Profiles:
#    balanced, performance, gaming, competitive, productivity,
#    privacy, minimal, custom
#
#  Usage:
#    EBOS-Profiles.ps1 -List
#    EBOS-Profiles.ps1 -Show
#    EBOS-Profiles.ps1 -Apply gaming
#    EBOS-Profiles.ps1 -Undo          # revert last profile application
# =====================================================================
param([switch]$List, [switch]$Show, [string]$Apply, [switch]$Undo)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'EBOS-Core.ps1')
Assert-EBOSAdmin

$profileState = Join-Path $script:EBOSOtherDir 'profile.json'

# ------------------------------------------------------------------ defs
# Power scheme GUIDs: balanced = 381b4222-f694-41f0-9685-ff5bb260df2e
# high performance = 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
# ultimate = e9a42b02-d5df-448d-aa66-1f0f8dde05f7 (falls back to high perf)
$definitions = @{
    balanced = [ordered]@{
        description   = 'Balanced defaults. Recommended for most systems.'
        powerScheme   = '381b4222-f694-41f0-9685-ff5bb260df2e'
        transparency  = 1
        animations    = 1
        visualFx      = 0    # let Windows decide
        backgroundApps = 1
        gameMode      = 1
        gameDvr       = 0
        mouseAccel    = 0    # pointer precision off (EBOS default)
        glassQuality  = 'Balanced'
    }
    performance = [ordered]@{
        description   = 'Prioritizes responsiveness over eye-candy.'
        powerScheme   = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
        transparency  = 1
        animations    = 0
        visualFx      = 1    # best performance
        backgroundApps = 0
        gameMode      = 1
        gameDvr       = 0
        mouseAccel    = 0
        glassQuality  = 'Performance'
    }
    gaming = [ordered]@{
        description   = 'Full-screen gaming: performance + Game Mode + low-latency input.'
        powerScheme   = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
        transparency  = 1
        animations    = 0
        visualFx      = 1
        backgroundApps = 0
        gameMode      = 1
        gameDvr       = 0
        mouseAccel    = 0
        glassQuality  = 'Performance'
    }
    competitive = [ordered]@{
        description   = 'Competitive gaming: minimal overhead, raw input, compact taskbar.'
        powerScheme   = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
        transparency  = 0
        animations    = 0
        visualFx      = 1
        backgroundApps = 0
        gameMode      = 1
        gameDvr       = 0
        mouseAccel    = 0
        glassQuality  = 'Compatibility'
    }
    productivity = [ordered]@{
        description   = 'Office / creative work: balanced power, full notifications, full glass.'
        powerScheme   = '381b4222-f694-41f0-9685-ff5bb260df2e'
        transparency  = 1
        animations    = 1
        visualFx      = 2    # best appearance
        backgroundApps = 1
        gameMode      = 1
        gameDvr       = 0
        mouseAccel    = 1    # default Windows pointer behavior
        glassQuality  = 'High'
    }
    privacy = [ordered]@{
        description   = 'Privacy-first: minimal visual effects, conservative services.'
        powerScheme   = '381b4222-f694-41f0-9685-ff5bb260df2e'
        transparency  = 1
        animations    = 1
        visualFx      = 0
        backgroundApps = 0
        gameMode      = 1
        gameDvr       = 0
        mouseAccel    = 0
        glassQuality  = 'Balanced'
    }
    minimal = [ordered]@{
        description   = 'Fewest effects possible: opaque surfaces, no animations.'
        powerScheme   = '381b4222-f694-41f0-9685-ff5bb260df2e'
        transparency  = 0
        animations    = 0
        visualFx      = 1
        backgroundApps = 0
        gameMode      = 0
        gameDvr       = 0
        mouseAccel    = 0
        glassQuality  = 'Compatibility'
    }
    custom = [ordered]@{
        description   = 'User-defined. Edit via the EBOS Dashboard; stored in profile.json.'
    }
}

if ($List) {
    Write-Output 'EBOS profiles:'
    foreach ($k in $definitions.Keys) { Write-Output ('  {0,-12} {1}' -f $k, $definitions[$k].description) }
    exit 0
}

if ($Show) {
    if (Test-Path $profileState) { Get-Content $profileState -Raw } else { Write-Output 'No profile has been applied yet.' }
    exit 0
}

if ($Undo) {
    $setPath = Join-Path $script:EBOSOtherDir 'changeset-profile.json'
    if (Test-Path $setPath) {
        Undo-EBOSChangeSet -ChangeSet (Load-EBOSChangeSet -Path $setPath)
        Remove-Item $profileState -ErrorAction SilentlyContinue
        Write-Output 'Last profile application reverted.'
    } else { Write-Output 'No captured profile change-set to revert.' }
    exit 0
}

if (!$Apply) { Write-Output 'EBOS Profiles — use -List, -Show, -Apply <name> or -Undo.'; exit 0 }

$key = $Apply.ToLowerInvariant()
if (!$definitions.Contains($key)) { Write-Error ("Unknown profile '$Apply'. Use -List to see available profiles."); exit 1 }
if ($key -eq 'custom') { Write-Error 'The custom profile is edited via the EBOS Dashboard, not applied directly.'; exit 1 }
$def = $definitions[$key]

# --------------------------------------------------------------- apply
$changeSet = New-Object System.Collections.ArrayList
$advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$gameBar  = 'HKCU:\Software\Microsoft\GameBar'
$gameDvr  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'
$personal = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'

# Power scheme
try { powercfg /setactive $def.powerScheme | Out-Null } catch { Write-Output 'Power scheme could not be switched (using active scheme).' }

# Appearance
Set-EBOSRegistry -Path $personal -Name 'EnableTransparency' -Data $def.transparency -ChangeSet $changeSet
Set-EBOSRegistry -Path $personal -Name 'AppsUseLightTheme'  -Data 1 -ChangeSet $changeSet
Set-EBOSRegistry -Path $advanced -Name 'TaskbarAl'          -Data 1 -ChangeSet $changeSet   # centered (Windows 11 style)
Set-EBOSRegistry -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name 'MinAnimate' -Data $def.animations -ChangeSet $changeSet
Set-EBOSRegistry -Path $advanced -Name 'TaskbarAnimations'  -Data $def.animations -ChangeSet $changeSet
Set-EBOSRegistry -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Data $def.visualFx -ChangeSet $changeSet

# Background apps (Windows 11 build-dependent; harmless if ignored)
Set-EBOSRegistry -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Name 'GlobalUserDisabled' -Data ($def.backgroundApps -bxor 1) -ChangeSet $changeSet

# Gaming
Set-EBOSRegistry -Path $gameBar -Name 'AllowAutoGameMode'  -Data $def.gameMode -ChangeSet $changeSet
Set-EBOSRegistry -Path $gameBar -Name 'AutoGameModeEnabled' -Data $def.gameMode -ChangeSet $changeSet
Set-EBOSRegistry -Path $gameDvr -Name 'AppCaptureEnabled'   -Data $def.gameDvr -ChangeSet $changeSet
Set-EBOSRegistry -Path 'HKCU:\System\CurrentControlSet\Control\Mouse' -Name 'MouseSpeed' -Data $def.mouseAccel -ChangeSet $changeSet

# Glass quality
$glass = Join-Path $here 'EBOS-Glass.ps1'
if (Test-Path $glass) { & $glass -Quality $def.glassQuality -Quiet }

# Persist state + change-set
$null = Save-EBOSChangeSet -ChangeSet $changeSet -Label 'profile'
@{ profile = $key; applied = (Get-Date).ToString('o'); settings = $def } | ConvertTo-Json -Depth 4 | Set-Content $profileState -Encoding UTF8
Write-EBOSLog -Message "Applied EBOS profile '$key'." -Module 'Profiles' -Change ('apply-' + $key) -Status 'SUCCESS' -Rollback 'AVAILABLE'

Restart-EBOSExplorer | Out-Null
Write-Output ("EBOS profile '$key' applied. Undo any time with: EBOS-Profiles.ps1 -Undo")
exit 0
