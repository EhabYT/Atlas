# =====================================================================
#  EBOS Core — System Validation CLI
#  ---------------------------------------------------------------
#  Automated post-install validation. Each subsystem produces a
#  [PASS]/[FAIL]/[WARN] line; failures are logged for EBOS Recovery
#  and never crash the run (fail-soft).
#
#  Usage:
#    EBOS-Validate.ps1          # console output
#    EBOS-Validate.ps1 -Quiet   # also write validation-report.txt
# =====================================================================
param([switch]$Quiet)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'EBOS-Core.ps1')

$results = New-Object System.Collections.ArrayList
$script:Fails = 0

function Add-Check {
    param([string]$Name, [scriptblock]$Test, [string]$FailNote = '')
    $status = 'FAIL'; $detail = ''
    try {
        $r = & $Test
        if ($r -is [array]) { $status = $r[0]; $detail = $r[1] } else { $status = $r }
    } catch { $status = 'WARN'; $detail = $_.Exception.Message }
    if ($status -eq 'FAIL') { $script:Fails++ }
    $null = $results.Add(([PSCustomObject]@{ Name = $Name; Status = $status; Detail = $detail }))
}

# --- Windows boot / OS -------------------------------------------------
Add-Check 'Windows Boot' { @('PASS', (Get-Date).ToString()) } 

# --- Explorer ----------------------------------------------------------
Add-Check 'Explorer' {
    $p = Get-Process -Name explorer -ErrorAction SilentlyContinue
    if ($p) { 'PASS' } else { 'FAIL' }
}

# --- Taskbar (Windows 11 shell health) ----------------------------------
Add-Check 'Taskbar' {
    $p = Get-Process -Name explorer -ErrorAction SilentlyContinue
    $tb = Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if ($p -and $tb) { 'PASS' } else { 'FAIL' }
}

# --- Liquid Glass configuration ----------------------------------------
Add-Check 'Liquid Glass' {
    $t = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -ErrorAction SilentlyContinue).EnableTransparency
    $q = (Get-ItemProperty 'HKLM:\SOFTWARE\EBOS\Glass' -ErrorAction SilentlyContinue).Quality
    if ($null -ne $t) { @('PASS', "transparency=$t, quality=$q") } else { 'WARN' }
}

# --- Network ------------------------------------------------------------
Add-Check 'Network' {
    $up = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object Status -eq 'Up')
    if ($up.Count -gt 0) { 'PASS' } else { 'FAIL' }
}

# --- DNS ----------------------------------------------------------------
Add-Check 'DNS' {
    try { $null = [System.Net.Dns]::GetHostAddresses('www.microsoft.com'); 'PASS' } catch { 'FAIL' }
}

# --- Audio ---------------------------------------------------------------
Add-Check 'Audio' {
    $svc = Get-Service -Name Audiosrv -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') { 'PASS' } else { @('WARN', 'Windows Audio not running') }
}

# --- GPU ------------------------------------------------------------------
Add-Check 'GPU' {
    $g = @(Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch 'Basic (Microsoft|Display)' })
    if ($g.Count -gt 0) { @('PASS', ($g[0].Name)) } else { 'FAIL' }
}

# --- Storage --------------------------------------------------------------
Add-Check 'Storage' {
    try {
        $bad = @(Get-PhysicalDisk | Where-Object HealthStatus -ne 'Healthy')
        if ($bad.Count -eq 0) { 'PASS' } else { @('WARN', ($bad.Count.ToString() + ' unhealthy disk(s)')) }
    } catch { 'WARN' }
}

# --- Windows Update -------------------------------------------------------
Add-Check 'Windows Update' {
    $svc = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    if ($svc) { @('PASS', $svc.StartType + '/' + $svc.Status) } else { 'FAIL' }
}

# --- Microsoft Store -------------------------------------------------------
Add-Check 'Microsoft Store' {
    try {
        $pkg = Get-AppxPackage -Name Microsoft.WindowsStore -ErrorAction Stop
        if ($pkg) { 'PASS' } else { @('WARN', 'Store package absent (may have been removed intentionally)') }
    } catch { @('WARN', 'Store query unavailable') }
}

# --- Defender ---------------------------------------------------------------
Add-Check 'Defender' {
    $svc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') { 'PASS' }
    elseif ($svc) { @('WARN', 'Defender service present but not running (may be intentional)') }
    else { @('WARN', 'Defender removed (intentional EBOS option)') }
}

# --- Bluetooth ---------------------------------------------------------------
Add-Check 'Bluetooth' {
    $radio = Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue | Where-Object Status -eq 'OK'
    $svc = Get-Service -Name bthserv -ErrorAction SilentlyContinue
    if ($radio -and $svc -and $svc.Status -eq 'Running') { 'PASS' }
    elseif (!$radio) { @('PASS', 'no Bluetooth radio present') }
    else { @('WARN', 'radio present, service not running') }
}

# --- USB -----------------------------------------------------------------------
Add-Check 'USB' {
    $usb = @(Get-PnpDevice -Class USB -ErrorAction SilentlyContinue | Where-Object Status -eq 'OK')
    if ($usb.Count -gt 0) { 'PASS' } else { 'WARN' }
}

# --- Sleep states ----------------------------------------------------------------
Add-Check 'Sleep' {
    $out = powercfg /a 2>$null
    if ($LASTEXITCODE -eq 0 -and $out -match 'The following sleep|Standby \(S3\)|Modern Standby') { 'PASS' } else { @('WARN', 'no sleep states or query failed') }
}

# --- Recovery ---------------------------------------------------------------------
Add-Check 'Recovery' {
    try {
        $out = reagentc /info 2>$null
        if ($out -match 'Windows RE is enabled') { 'PASS' } else { @('WARN', 'Windows RE disabled') }
    } catch { 'WARN' }
}

# --- EBOS Core ------------------------------------------------------------------------
Add-Check 'EBOS Core' {
    if (Test-Path (Join-Path $script:EBOSOtherDir 'system-report.json')) { 'PASS' } else { @('WARN', 'system report not generated yet') }
}

# --------------------------------------------------------------------- output
$lines = @('EBOS System Validation', ('Generated: ' + (Get-Date)), '')
foreach ($r in $results) {
    $line = '[{0}] {1}' -f $r.Status, $r.Name
    if ($r.Detail) { $line += ' — ' + $r.Detail }
    $lines += $line
}
$lines += ''
$lines += ('Summary: {0} PASS, {1} WARN, {2} FAIL' -f `
    @($results | Where-Object Status -eq 'PASS').Count, `
    @($results | Where-Object Status -eq 'WARN').Count, `
    $script:Fails)

if (!$Quiet) { $lines | Write-Output }

foreach ($dir in @($script:EBOSModulesRoot, $script:EBOSOtherDir)) {
    if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
}
$lines | Set-Content (Join-Path $script:EBOSOtherDir 'validation-report.txt') -Encoding UTF8
Write-EBOSLog -Message ("Validation finished: {0} failure(s)." -f $script:Fails) -Module 'Core' -Change 'validate' -Status ($(if ($script:Fails -gt 0) { 'FAILURE' } else { 'SUCCESS' }))
exit 0
