# #region agent log
$root = Split-Path $PSScriptRoot -Parent
$logPath = Join-Path $root 'debug-ade3fd.log'
function Write-DebugLog($hypothesisId, $message, $data) {
    $entry = @{
        sessionId = 'ade3fd'
        runId = 'param-fix'
        hypothesisId = $hypothesisId
        location = 'validate-pbip-parameters.ps1'
        message = $message
        data = $data
        timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    } | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $entry -Encoding UTF8
}
# #endregion

$tables = @(
    @{ Name = 'Metric Mode'; Path = 'Yarn Petals..SemanticModel\definition\tables\Metric Mode.tmdl' },
    @{ Name = 'Time Grain'; Path = 'Yarn Petals..SemanticModel\definition\tables\Time Grain.tmdl' }
)

foreach ($t in $tables) {
    $path = Join-Path $root $t.Path
    $text = Get-Content -Path $path -Raw
    $hasExtended = $text -match 'extendedProperty ParameterMetadata'
    $hasAnnotation = $text -match 'annotation PBI_ParameterMetadata'
    $hasRelated = $text -match 'relatedColumnDetails'
    $hasGroupBy = $text -match 'groupByColumn:'
    $hasNameof = $text -match 'NAMEOF'

    Write-DebugLog 'H1' "extendedProperty vs annotation - $($t.Name)" @{
        table = $t.Name
        hasExtendedProperty = $hasExtended
        hasOldAnnotation = $hasAnnotation
        valid = ($hasExtended -and -not $hasAnnotation)
    }
    Write-DebugLog 'H2' "relatedColumnDetails - $($t.Name)" @{
        table = $t.Name
        hasRelatedColumnDetails = $hasRelated
        hasGroupByColumn = $hasGroupBy
        valid = ($hasRelated -and $hasGroupBy)
    }
    Write-DebugLog 'H4' "NAMEOF in partition - $($t.Name)" @{
        table = $t.Name
        hasNameof = $hasNameof
        valid = $hasNameof
    }
}

$metricsPath = Join-Path $root 'Yarn Petals..SemanticModel\definition\tables\Metrics.tmdl'
$metrics = Get-Content -Path $metricsPath -Raw
$usesNameSwitch = $metrics -match 'SELECTEDVALUE \( ''Metric Mode''\[Metric Mode\] \)'
Write-DebugLog 'H3' 'Selected Metric Value uses display name SWITCH' @{
    usesMetricModeLabel = $usesNameSwitch
    valid = $usesNameSwitch
}

Write-Output 'Parameter validation complete. See debug-ade3fd.log'
