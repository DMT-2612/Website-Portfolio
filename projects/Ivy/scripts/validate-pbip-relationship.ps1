# #region agent log
$logPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'debug-ade3fd.log'
$relPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Yarn Petals..SemanticModel\definition\relationships.tmdl'
function Write-DebugLog($hypothesisId, $message, $data) {
    $entry = @{
        sessionId = 'ade3fd'
        runId = 'post-fix'
        hypothesisId = $hypothesisId
        location = 'validate-pbip-relationship.ps1'
        message = $message
        data = $data
        timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    } | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $entry -Encoding UTF8
}
# #endregion

$text = Get-Content -Path $relPath -Raw
$fromCard = if ($text -match 'fromCardinality:\s*(\w+)') { $Matches[1] } else { 'MISSING' }
$toCard = if ($text -match 'toCardinality:\s*(\w+)') { $Matches[1] } else { 'MISSING' }
$fromCol = if ($text -match 'fromColumn:\s*(\S+)') { $Matches[1] } else { 'MISSING' }
$toCol = if ($text -match 'toColumn:\s*(\S+)') { $Matches[1] } else { 'MISSING' }

Write-DebugLog 'H1' 'fromCardinality must be many' @{ fromCardinality = $fromCard; valid = ($fromCard -eq 'many') }
Write-DebugLog 'H2' 'toCardinality should be one for star schema' @{ toCardinality = $toCard; valid = ($toCard -eq 'one') }
Write-DebugLog 'H3' 'from=Orders fact, to=DimDate dimension' @{ fromColumn = $fromCol; toColumn = $toCol; valid = ($fromCol -eq 'Orders.Date' -and $toCol -eq 'DimDate.Date') }

$allValid = ($fromCard -eq 'many') -and ($toCard -eq 'one') -and ($fromCol -eq 'Orders.Date')
Write-DebugLog 'H4' 'relationship validation summary' @{ allValid = $allValid }
Write-Output "Validation: allValid=$allValid from=$fromCol ($fromCard) to=$toCol ($toCard)"
