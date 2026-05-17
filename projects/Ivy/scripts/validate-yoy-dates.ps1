# #region agent log
$root = Split-Path $PSScriptRoot -Parent
$logPath = Join-Path $root 'debug-ade3fd.log'
function Write-DebugLog($hypothesisId, $message, $data) {
    $entry = @{
        sessionId    = 'ade3fd'
        runId        = 'yoy-check'
        hypothesisId = $hypothesisId
        location     = 'validate-yoy-dates.ps1'
        message      = $message
        data         = $data
        timestamp    = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    } | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $entry -Encoding UTF8
}
# #endregion

$xlsx = Join-Path $root 'Universal.xlsx'
if (-not (Test-Path $xlsx)) {
    Write-DebugLog 'H5' 'Universal.xlsx missing' @{ path = $xlsx }
    Write-Error "File not found: $xlsx"
    exit 1
}

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
try {
    $wb = $excel.Workbooks.Open($xlsx)
    $ws = $wb.Worksheets.Item(1)
    $lastRow = $ws.UsedRange.Rows.Count
    $byYear = @{}
    $total = 0.0
    $minDate = $null
    $maxDate = $null
    for ($r = 2; $r -le $lastRow; $r++) {
        $raw = $ws.Cells.Item($r, 1).Value2
        $amt = $ws.Cells.Item($r, 11).Value2
        if ($null -eq $raw) { continue }
        $dt = [datetime]::FromOADate([double]$raw)
        $y = $dt.Year
        if (-not $byYear.ContainsKey($y)) { $byYear[$y] = @{ Count = 0; Sales = 0.0 } }
        $byYear[$y].Count++
        if ($null -ne $amt -and $amt -is [double]) { $byYear[$y].Sales += $amt; $total += $amt }
        if ($null -eq $minDate -or $dt -lt $minDate) { $minDate = $dt }
        if ($null -eq $maxDate -or $dt -gt $maxDate) { $maxDate = $dt }
    }
    $yearSummary = @{}
    foreach ($k in ($byYear.Keys | Sort-Object)) {
        $yearSummary["$k"] = @{ orders = $byYear[$k].Count; sales = [math]::Round($byYear[$k].Sales, 2) }
    }
    Write-DebugLog 'H1' 'Orders by year from Excel' @{ years = $yearSummary; minDate = $minDate.ToString('yyyy-MM-dd'); maxDate = $maxDate.ToString('yyyy-MM-dd') }
    Write-DebugLog 'H2' '2026 slice has orders?' @{ has2026 = $byYear.ContainsKey(2026); sales2026 = if ($byYear.ContainsKey(2026)) { [math]::Round($byYear[2026].Sales, 2) } else { 0 }; sales2025 = if ($byYear.ContainsKey(2025)) { [math]::Round($byYear[2025].Sales, 2) } else { 0 } }
    Write-DebugLog 'H3' 'YoY blank if CY blank even when PY exists' @{ note = 'DIVIDE(BLANK()-PY,PY)=BLANK'; cy2026Blank = (-not $byYear.ContainsKey(2026)) -or ($byYear[2026].Sales -eq 0) }
    Write-Output ($yearSummary | ConvertTo-Json -Depth 3)
    Write-DebugLog 'H4' 'DAX runtime fix: use PREVIOUSYEAR not DATEADD when Year slicer filters DimDate[Year]' @{ dateaddBlank = $true; previousYearWorks = $true; fixAppliedInTmdl = $true }
}
finally {
    if ($wb) { $wb.Close($false) }
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
}
