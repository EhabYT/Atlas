# =====================================================================
#  EBOS Core — System Detection CLI
#  ---------------------------------------------------------------
#  Produces the EBOS system report (hardware + compatibility) used by
#  the optimization engine, Liquid Glass quality selection and docs.
#
#  Usage:
#    EBOS-Detect.ps1                # print report to console
#    EBOS-Detect.ps1 -WriteReport   # write JSON + TXT to EBOSModules\Other
# =====================================================================
param([switch]$WriteReport, [switch]$Quiet)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'EBOS-Core.ps1')

$info = Get-EBOSSystemInfo
$compat = Get-EBOSCompatibility
$report = [PSCustomObject]@{ System = $info; Compatibility = $compat }

if ($WriteReport) {
    foreach ($dir in @($script:EBOSModulesRoot, $script:EBOSOtherDir)) {
        if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
    }
    $jsonPath = Join-Path $script:EBOSOtherDir 'system-report.json'
    $txtPath  = Join-Path $script:EBOSOtherDir 'system-report.txt'
    $info | ConvertTo-Json -Depth 4 | Set-Content $jsonPath -Encoding UTF8

    $lines = @(
        '==============================================',
        ' EBOS SYSTEM REPORT',
        (' Generated: ' + (Get-Date)),
        '==============================================',
        (' Computer          : ' + $info.ComputerName),
        (' Windows           : {0} ({1}, build {2}.{3})' -f $info.WindowsName, $info.DisplayVersion, $info.Build, $info.UBR),
        (' Architecture      : ' + $info.Arch),
        (' Chassis           : ' + $info.Chassis),
        (' Manufacturer/Model: {0} / {1}' -f $info.Manufacturer, $info.Model),
        (' CPU               : {0} ({1}C/{2}T)' -f $info.CPU, $info.Cores, $info.LogicalProcessors),
        (' RAM               : {0} GB' -f $info.RAMGB),
        (' GPU               : ' + ($(if ($info.GPUs.Count) { $info.GPUs -join '; ' } else { 'none detected' }))),
        (' GPU perf class    : ' + $info.GPUPerfClass),
        (' Firmware          : ' + $info.Firmware),
        (' Virtualized       : ' + $info.Virtualized + ' ' + $info.VirtualizationNote),
        (' Battery present   : ' + $info.BatteryPresent),
        (' Storage           : ' + ($info.Storage -join ' | ')),
        (' Network (up)      : ' + ($(if ($info.NetworkAdapters.Count) { $info.NetworkAdapters -join '; ' } else { 'none detected' }))),
        '----------------------------------------------',
        (' Compatibility     : ' + $compat.Verdict + ' (supported builds: ' + ($compat.SupportedBuilds -join ', ') + ')'),
        (' Recommendation    : ' + $compat.Recommendation),
        '=============================================='
    )
    $lines | Set-Content $txtPath -Encoding UTF8
    Write-EBOSLog -Message 'System detection report generated.' -Module 'Core' -Change 'detect' -Status 'SUCCESS'
    if (!$Quiet) { $lines | Write-Output }
} else {
    $report | ConvertTo-Json -Depth 4 | Write-Output
}
exit 0
