# #region agent log
$root = Split-Path $PSScriptRoot -Parent
$logPath = Join-Path $root 'debug-ade3fd.log'
function Write-DebugLog($hypothesisId, $message, $data) {
    $entry = @{
        sessionId = 'ade3fd'
        runId = 'theme-audit'
        hypothesisId = $hypothesisId
        location = 'validate-pbip-theme.ps1'
        message = $message
        data = $data
        timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    } | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $entry -Encoding UTF8
}
# #endregion

$plan = @{
    background = '#FDE8EF'
    foreground = '#9B6B7A'
    tableAccent = '#E8799E'
    good = '#FFB6C1'
    dataColors = @('#FF69B4','#FF9BAA','#DA70D6','#FFDAB9','#E0B0C0','#FA8072')
}

$themePath = Join-Path $root 'Yarn Petals..Report\StaticResources\RegisteredResources\YarnPetalsTheme.json'
$reportPath = Join-Path $root 'Yarn Petals..Report\definition\report.json'
$pagePath = Join-Path $root 'Yarn Petals..Report\definition\pages\cb48b30cc8da4aad2bd0\page.json'

$theme = Get-Content $themePath -Raw | ConvertFrom-Json
$report = Get-Content $reportPath -Raw | ConvertFrom-Json
$page = Get-Content $pagePath -Raw

Write-DebugLog 'T1' 'Core theme tokens vs plan' @{
    backgroundMatch = ($theme.background -eq $plan.background)
    foregroundMatch = ($theme.foreground -eq $plan.foreground)
    tableAccentMatch = ($theme.tableAccent -eq $plan.tableAccent)
    goodMatch = ($theme.good -eq $plan.good)
}

Write-DebugLog 'T2' 'dataColors count and first 6' @{
    count = $theme.dataColors.Count
    expectedCount = 6
    firstSixMatch = (($theme.dataColors[0..5] -join ',') -eq ($plan.dataColors -join ','))
}

$regItem = $report.resourcePackages | Where-Object { $_.name -eq 'RegisteredResources' } | ForEach-Object { $_.items } | Where-Object { $_.name -eq 'YarnPetalsTheme' }
Write-DebugLog 'T3' 'report.json theme registration' @{
    hasCustomTheme = ($null -ne $report.themeCollection.customTheme)
    customThemeName = $report.themeCollection.customTheme.name
    resourcePath = $regItem.path
    pathHasJson = ($regItem.path -like '*.json')
}

$pageBg = if ($page -match "#FDE8EF") { $true } else { $false }
Write-DebugLog 'T4' 'page.json canvas background' @{ pageBackgroundFDE8EF = $pageBg }

$bytes = [System.IO.File]::ReadAllBytes($themePath)
$noBom = -not ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF)
Write-DebugLog 'T5' 'theme file UTF-8 without BOM' @{ noBom = $noBom; firstByte = $bytes[0] }

Write-Output "Theme audit written to debug-ade3fd.log"
