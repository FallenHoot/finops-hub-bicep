<#
.SYNOPSIS
    Extracts dashboard KQL into per-query folders and generates FOCUS alignment reports.

.DESCRIPTION
    Reads dashboards/dashboard-FinOps-hub_2.json, maps tiles to query IDs, extracts each
    query into its own folder, and performs a heuristic FOCUS comparison based on
    Costs_final_v1_2 schema columns from modules/scripts/IngestionSetup_v1_2.kql.

    Output is written to docs/library/dashboard-kql.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,

    [Parameter(Mandatory = $false)]
    [string]$DashboardPath = '',

    [Parameter(Mandatory = $false)]
    [string]$SchemaScriptPath = '',

    [Parameter(Mandatory = $false)]
    [string]$OutputRoot = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($DashboardPath)) {
    $DashboardPath = Join-Path $RepoRoot 'dashboards/dashboard-FinOps-hub_2.json'
}

if ([string]::IsNullOrWhiteSpace($SchemaScriptPath)) {
    $SchemaScriptPath = Join-Path $RepoRoot 'modules/scripts/IngestionSetup_v1_2.kql'
}

if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $RepoRoot 'docs/library/dashboard-kql'
}

if (-not (Test-Path $DashboardPath)) {
    throw "Dashboard file not found: $DashboardPath"
}

if (-not (Test-Path $SchemaScriptPath)) {
    throw "Schema script file not found: $SchemaScriptPath"
}

function Get-CostColumnsFromSchema {
    param([string]$Path)

    $content = Get-Content -Path $Path -Raw
    $block = [regex]::Match(
        $content,
        '(?s)\.create-merge table\s+Costs_final_v1_2\s*\((.*?)\)\s*\r?\n\s*// Update policy'
    )

    if (-not $block.Success) {
        throw 'Could not find Costs_final_v1_2 schema block in IngestionSetup_v1_2.kql.'
    }

    $columns = @()
    foreach ($line in ($block.Groups[1].Value -split "`r?`n")) {
        $m = [regex]::Match($line, '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:')
        if ($m.Success) {
            $columns += $m.Groups[1].Value
        }
    }

    return $columns | Sort-Object -Unique
}

function Convert-ToSlug {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return 'query'
    }

    $slug = $Value.ToLowerInvariant()
    $slug = [regex]::Replace($slug, '[^a-z0-9]+', '-')
    $slug = $slug.Trim('-')
    if ([string]::IsNullOrWhiteSpace($slug)) {
        return 'query'
    }
    if ($slug.Length -gt 48) {
        return $slug.Substring(0, 48).Trim('-')
    }
    return $slug
}

function Get-MatchingColumns {
    param(
        [string]$QueryText,
        [string[]]$Columns
    )

    $columnMatches = @()
    foreach ($col in $Columns) {
        $pattern = "(?i)(?<![A-Za-z0-9_])$([regex]::Escape($col))(?![A-Za-z0-9_])"
        if ($QueryText -match $pattern) {
            $columnMatches += $col
        }
    }

    return $columnMatches | Sort-Object -Unique
}

function Get-Assessment {
    param(
        [string[]]$FocusColumns,
        [string[]]$ExtensionColumns,
        [string]$QueryText,
        [string[]]$UsedVariables
    )

    if ($QueryText.TrimStart().StartsWith('.show cluster extents', [System.StringComparison]::OrdinalIgnoreCase)) {
        return 'metadata-query'
    }

    if ($QueryText -match '(?i)\bHubSettings\b') {
        return 'metadata-query'
    }

    if ($FocusColumns.Count -gt 0) {
        return 'focus-aligned'
    }

    if ($ExtensionColumns.Count -gt 0) {
        return 'focus-with-extensions-only'
    }

    if ($UsedVariables.Count -gt 0) {
        return 'indirect-focus-via-shared-variable'
    }

    return 'needs-manual-review'
}

if (-not (Test-Path $OutputRoot)) {
    New-Item -Path $OutputRoot -ItemType Directory -Force | Out-Null
}

$queriesRoot = Join-Path $OutputRoot 'queries'
if (-not (Test-Path $queriesRoot)) {
    New-Item -Path $queriesRoot -ItemType Directory -Force | Out-Null
}

$dashboard = Get-Content -Path $DashboardPath -Raw | ConvertFrom-Json -Depth 100
$costColumns = Get-CostColumnsFromSchema -Path $SchemaScriptPath

$tilesByQuery = @{}
foreach ($tile in $dashboard.tiles) {
    if ($null -eq $tile.queryRef -or $null -eq $tile.queryRef.queryId) { continue }
    $qid = [string]$tile.queryRef.queryId
    if (-not $tilesByQuery.ContainsKey($qid)) {
        $tilesByQuery[$qid] = New-Object System.Collections.Generic.List[object]
    }

    $title = if ([string]::IsNullOrWhiteSpace([string]$tile.title)) { '(untitled tile)' } else { [string]$tile.title }
    $tilesByQuery[$qid].Add([PSCustomObject]@{
        tileId = [string]$tile.id
        title = $title
        pageId = [string]$tile.pageId
        visualType = [string]$tile.visualType
    })
}

$summary = New-Object System.Collections.Generic.List[object]

for ($i = 0; $i -lt $dashboard.queries.Count; $i++) {
    $query = $dashboard.queries[$i]
    $queryId = [string]$query.id
    $queryText = [string]$query.text
    $usedVars = @()
    if ($null -ne $query.usedVariables) {
        $usedVars = @($query.usedVariables | ForEach-Object { [string]$_ })
    }

    $queryTiles = @()
    if ($tilesByQuery.ContainsKey($queryId)) {
        $queryTiles = @($tilesByQuery[$queryId].ToArray())
    }

    $primaryTitle = 'unbound-query'
    if ($queryTiles.Count -gt 0) {
        $primaryTitle = [string]$queryTiles[0].title
    }
    $folderName = '{0:D3}-{1}-{2}' -f ($i + 1), (Convert-ToSlug -Value $primaryTitle), $queryId.Substring(0, 8)
    $queryFolder = Join-Path $queriesRoot $folderName

    if (-not (Test-Path $queryFolder)) {
        New-Item -Path $queryFolder -ItemType Directory -Force | Out-Null
    }

    $matchedColumns = Get-MatchingColumns -QueryText $queryText -Columns $costColumns
    $focusColumns = @($matchedColumns | Where-Object { -not $_.StartsWith('x_') })
    $extensionColumns = @($matchedColumns | Where-Object { $_.StartsWith('x_') })
    $assessment = Get-Assessment -FocusColumns $focusColumns -ExtensionColumns $extensionColumns -QueryText $queryText -UsedVariables $usedVars

    $metadata = [PSCustomObject]@{
        queryId = $queryId
        folder = $folderName
        primaryTitle = $primaryTitle
        tiles = $queryTiles
        dataSourceId = [string]$query.dataSource.dataSourceId
        usedVariables = $usedVars
        focusComparison = [PSCustomObject]@{
            assessment = $assessment
            focusColumnsUsed = $focusColumns
            extensionColumnsUsed = $extensionColumns
            heuristicNotes = @(
                'Column-level comparison is heuristic and based on Costs_final_v1_2 schema.',
                'FOCUS validation should be finalized against official v1.3 sources and migration backlog.'
            )
        }
    }

    Set-Content -Path (Join-Path $queryFolder 'query.kql') -Value $queryText -Encoding utf8
    $metadata | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path $queryFolder 'metadata.json') -Encoding utf8

    $readmeLines = @(
        '# Dashboard Query',
        '',
        "- Query ID: $queryId",
        "- Assessment: $assessment",
        "- Tile count: $($queryTiles.Count)",
        '',
        '## Linked tiles',
        ''
    )

    if ($queryTiles.Count -eq 0) {
        $readmeLines += '- (No direct tile reference; likely a base/helper/parameter query)'
    }
    else {
        foreach ($tileRef in $queryTiles) {
            $readmeLines += "- $($tileRef.title) ($($tileRef.visualType))"
        }
    }

    $readmeLines += @(
        '',
        '## FOCUS comparison (heuristic)',
        '',
        "- FOCUS columns used: $($focusColumns.Count)",
        "- Extension columns (x_*) used: $($extensionColumns.Count)",
        "- Variables: $(if ($usedVars.Count -gt 0) { ($usedVars -join ', ') } else { '(none)' })",
        '',
        'See metadata.json for structured details.'
    )

    Set-Content -Path (Join-Path $queryFolder 'README.md') -Value ($readmeLines -join "`r`n") -Encoding utf8

    $summary.Add([PSCustomObject]@{
        queryId = $queryId
        folder = $folderName
        primaryTitle = $primaryTitle
        tileCount = $queryTiles.Count
        assessment = $assessment
        focusColumnsUsed = $focusColumns.Count
        extensionColumnsUsed = $extensionColumns.Count
        usedVariables = $usedVars
    })
}

$summaryPath = Join-Path $OutputRoot 'summary.json'
$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $summaryPath -Encoding utf8

$assessmentStats = $summary | Group-Object -Property assessment | Sort-Object -Property Count -Descending
$statsObj = [PSCustomObject]@{}
foreach ($g in $assessmentStats) {
    $statsObj | Add-Member -NotePropertyName $g.Name -NotePropertyValue $g.Count
}

$coverage = [PSCustomObject]@{
    generatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    dashboardPath = $DashboardPath
    schemaScriptPath = $SchemaScriptPath
    totalQueries = $summary.Count
    totalTileBoundQueries = ($summary | Where-Object { $_.tileCount -gt 0 }).Count
    assessmentBreakdown = $statsObj
    notes = @(
        'This is a heuristic FOCUS comparison and not a formal validator run.',
        'Repository is currently behind FOCUS v1.3; use docs/library/focus/focus-upgrade-backlog.md for migration planning.'
    )
}

$coverage | ConvertTo-Json -Depth 8 | Set-Content -Path (Join-Path $OutputRoot 'focus-comparison-summary.json') -Encoding utf8

$index = New-Object System.Collections.Generic.List[string]
$index.Add('# Dashboard KQL Query Library')
$index.Add('')
$index.Add('This library extracts every query in dashboards/dashboard-FinOps-hub_2.json into its own folder and compares referenced columns to the local FOCUS-style schema (Costs_final_v1_2).')
$index.Add('')
$index.Add('## Files')
$index.Add('')
$index.Add('- summary.json')
$index.Add('- focus-comparison-summary.json')
$index.Add('- queries/<nnn-...>/query.kql')
$index.Add('- queries/<nnn-...>/metadata.json')
$index.Add('- queries/<nnn-...>/README.md')
$index.Add('')
$index.Add('## Query index')
$index.Add('')
$index.Add('| # | Query ID | Primary tile | Assessment | Folder |')
$index.Add('|---:|---|---|---|---|')

for ($i = 0; $i -lt $summary.Count; $i++) {
    $row = $summary[$i]
    $folderRel = "queries/$($row.folder)"
    $title = [string]$row.primaryTitle
    if ([string]::IsNullOrWhiteSpace($title)) {
        $title = '(unbound-query)'
    }

    $safeTitle = $title.Replace('|', '\|')
    $index.Add("| $($i + 1) | $($row.queryId) | $safeTitle | $($row.assessment) | [$folderRel]($folderRel/README.md) |")
}

Set-Content -Path (Join-Path $OutputRoot 'README.md') -Value ($index -join "`r`n") -Encoding utf8

Write-Host "Extracted $($summary.Count) dashboard queries into: $queriesRoot"
Write-Host "Summary: $summaryPath"
Write-Host "FOCUS comparison: $(Join-Path $OutputRoot 'focus-comparison-summary.json')"