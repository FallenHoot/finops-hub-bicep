<#
.SYNOPSIS
    Builds a sheet-organized KQL library from the FinOps dashboard JSON.

.DESCRIPTION
    Reads dashboards/dashboard-FinOps-hub_2.json and produces one markdown file per
    dashboard sheet. Each file includes every tile-bound KQL query and an auto-generated
    explanation of what the query does.

    The script also writes an index file that links to every generated sheet file.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,

    [Parameter(Mandatory = $false)]
    [string]$DashboardPath = '',

    [Parameter(Mandatory = $false)]
    [string]$OutputRoot = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($DashboardPath)) {
    $DashboardPath = Join-Path $RepoRoot 'dashboards/dashboard-FinOps-hub_2.json'
}

if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $RepoRoot 'docs/library/dashboard-kql/sheets'
}

if (-not (Test-Path $DashboardPath)) {
    throw "Dashboard file not found: $DashboardPath"
}

if (-not (Test-Path $OutputRoot)) {
    New-Item -Path $OutputRoot -ItemType Directory -Force | Out-Null
}

function Convert-ToSlug {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return 'sheet'
    }

    $slug = $Value.ToLowerInvariant()
    $slug = [regex]::Replace($slug, '[^a-z0-9]+', '-')
    $slug = $slug.Trim('-')
    if ([string]::IsNullOrWhiteSpace($slug)) {
        return 'sheet'
    }
    return $slug
}

function Get-QueryExplanation {
    param(
        [string]$QueryText,
        [string[]]$UsedVariables
    )

    $clean = [string]$QueryText
    $operatorNames = @(
        'where', 'summarize', 'project', 'project-rename', 'project-away', 'project-keep',
        'extend', 'order', 'sort', 'top', 'render', 'join', 'lookup', 'mv-expand',
        'distinct', 'take', 'limit', 'union', 'serialize', 'evaluate', 'invoke', 'sample'
    )

    $tableCandidates = New-Object System.Collections.Generic.List[string]

    # Pattern: Source and pipe on the same line, e.g. Costs | summarize ...
    [regex]::Matches($clean, '(?im)^[ \t]*([A-Za-z_][A-Za-z0-9_]*)[ \t]*\|') |
        ForEach-Object { $tableCandidates.Add($_.Groups[1].Value) }

    # Pattern: Source on one line and pipe starts on next line.
    $lines = @($clean -split "`r?`n")
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()
        if ($line -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') { continue }

        $nextIdx = $i + 1
        while ($nextIdx -lt $lines.Count -and [string]::IsNullOrWhiteSpace($lines[$nextIdx])) {
            $nextIdx++
        }
        if ($nextIdx -ge $lines.Count) { continue }
        if ($lines[$nextIdx].TrimStart() -notmatch '^\|') { continue }

        $prevIdx = $i - 1
        while ($prevIdx -ge 0 -and [string]::IsNullOrWhiteSpace($lines[$prevIdx])) {
            $prevIdx--
        }
        $prevLine = if ($prevIdx -ge 0) { $lines[$prevIdx].Trim().ToLowerInvariant() } else { '' }

        # Exclude summarize-by fragments such as: by <newline> BillingPeriodStart <newline> | ...
        if ($prevLine -eq 'by' -or $prevLine -match '^,$') { continue }

        $tableCandidates.Add($line)
    }

    $tables = @($tableCandidates.ToArray()) |
        Where-Object { $operatorNames -notcontains $_.ToLowerInvariant() } |
        Sort-Object -Unique

    $whereLines = @(
        [regex]::Matches($clean, '(?im)^\s*\|\s*where\s+(.+)$') |
            ForEach-Object { $_.Groups[1].Value.Trim() }
    )

    $summaries = @(
        [regex]::Matches($clean, '(?im)^\s*\|\s*summarize\s+(.+)$') |
            ForEach-Object { $_.Groups[1].Value.Trim() }
    )

    $joins = @(
        [regex]::Matches($clean, '(?im)^\s*\|\s*join\s+(.+)$') |
            ForEach-Object { $_.Groups[1].Value.Trim() }
    )

    $projects = @(
        [regex]::Matches($clean, '(?im)^\s*\|\s*project(?:-rename|-away|-keep)?\s+(.+)$') |
            ForEach-Object { $_.Groups[1].Value.Trim() }
    )

    $sorts = @(
        [regex]::Matches($clean, '(?im)^\s*\|\s*(?:order\s+by|sort\s+by|top)\s+(.+)$') |
            ForEach-Object { $_.Groups[1].Value.Trim() }
    )

    $steps = New-Object System.Collections.Generic.List[string]

    if ($tables.Count -gt 0) {
        $steps.Add("Reads from: $($tables -join ', ').")
    }
    else {
        $steps.Add('Uses previously defined variables or helper query blocks as its primary input.')
    }

    if ($UsedVariables.Count -gt 0) {
        $steps.Add("Consumes shared variables: $($UsedVariables -join ', ').")
    }

    if ($whereLines.Count -gt 0) {
        $preview = ($whereLines | Select-Object -First 2) -join ' | '
        $steps.Add("Applies filters to narrow scope. Examples: $preview")
    }

    if ($summaries.Count -gt 0) {
        $preview = ($summaries | Select-Object -First 2) -join ' | '
        $steps.Add("Aggregates data with summarize. Examples: $preview")
    }

    if ($joins.Count -gt 0) {
        $preview = ($joins | Select-Object -First 2) -join ' | '
        $steps.Add("Combines datasets with join operations. Examples: $preview")
    }

    if ($projects.Count -gt 0) {
        $preview = ($projects | Select-Object -First 2) -join ' | '
        $steps.Add("Shapes output columns with project operations. Examples: $preview")
    }

    if ($sorts.Count -gt 0) {
        $preview = ($sorts | Select-Object -First 2) -join ' | '
        $steps.Add("Orders or ranks output for visualization. Examples: $preview")
    }

    $hasSeries = $clean -match '(?im)\|\s*make-series\b'
    if ($hasSeries) {
        $steps.Add('Builds a time series, commonly used for trend or forecast visuals.')
    }

    $hasParseJson = $clean -match '(?im)\bparse_json\b|\bextractjson\b|\bmv-expand\b'
    if ($hasParseJson) {
        $steps.Add('Expands or parses nested JSON-like structures before aggregation.')
    }

    return $steps
}

$dashboard = Get-Content -Path $DashboardPath -Raw | ConvertFrom-Json -Depth 100

$pagesById = @{}
for ($i = 0; $i -lt $dashboard.pages.Count; $i++) {
    $page = $dashboard.pages[$i]
    $name = [string]$page.name
    if ([string]::IsNullOrWhiteSpace($name)) {
        $name = [string]$page.displayName
    }
    if ([string]::IsNullOrWhiteSpace($name)) {
        $name = "Sheet $($i + 1)"
    }

    $pagesById[[string]$page.id] = [PSCustomObject]@{
        id = [string]$page.id
        name = $name
        order = $i + 1
    }
}

$queriesById = @{}
foreach ($query in $dashboard.queries) {
    $queriesById[[string]$query.id] = $query
}

$tilesByPage = @{}
foreach ($tile in $dashboard.tiles) {
    $pageId = [string]$tile.pageId
    if ([string]::IsNullOrWhiteSpace($pageId)) { continue }
    if (-not $tilesByPage.ContainsKey($pageId)) {
        $tilesByPage[$pageId] = New-Object System.Collections.Generic.List[object]
    }
    $tilesByPage[$pageId].Add($tile)
}

$indexLines = New-Object System.Collections.Generic.List[string]
$indexLines.Add('# Dashboard KQL Sheets')
$indexLines.Add('')
$indexLines.Add('This folder organizes dashboard KQL by sheet. Each section includes the full KQL and an explanation of what it does.')
$indexLines.Add('')
$indexLines.Add('## Sheet files')
$indexLines.Add('')

$sheetFiles = New-Object System.Collections.Generic.List[object]

$orderedPages = $pagesById.Values | Sort-Object order
foreach ($page in $orderedPages) {
    $pageTiles = @()
    if ($tilesByPage.ContainsKey($page.id)) {
        $pageTiles = @($tilesByPage[$page.id].ToArray() | Sort-Object @{Expression = { [int]$_.layout.y }}, @{Expression = { [int]$_.layout.x }}, @{Expression = { [string]$_.title }})
    }

    $slug = Convert-ToSlug -Value $page.name
    $fileName = ('{0:D2}-{1}.md' -f $page.order, $slug)
    $filePath = Join-Path $OutputRoot $fileName

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# $($page.name)")
    $lines.Add('')
    $lines.Add("- Page ID: $($page.id)")
    $lines.Add("- Tile count: $($pageTiles.Count)")
    $lines.Add('')

    if ($pageTiles.Count -eq 0) {
        $lines.Add('This sheet has no tiles in the current dashboard JSON.')
        $lines.Add('')
    }

    foreach ($tile in $pageTiles) {
        $tileTitle = [string]$tile.title
        if ([string]::IsNullOrWhiteSpace($tileTitle)) {
            $tileTitle = '(untitled tile)'
        }

        $lines.Add("## Tile: $tileTitle")
        $lines.Add('')
        $lines.Add("- Tile ID: $([string]$tile.id)")
        $lines.Add("- Visual: $([string]$tile.visualType)")

        $queryId = ''
        if ($null -ne $tile.queryRef) {
            $queryId = [string]$tile.queryRef.queryId
        }

        if ([string]::IsNullOrWhiteSpace($queryId) -or -not $queriesById.ContainsKey($queryId)) {
            $lines.Add('- Query ID: (none)')
            $lines.Add('')
            $lines.Add('### What this query does')
            $lines.Add('')
            $lines.Add('This tile does not reference a query in the queries collection.')
            $lines.Add('')
            continue
        }

        $query = $queriesById[$queryId]
        $queryText = [string]$query.text
        $usedVariables = @()
        if ($null -ne $query.usedVariables) {
            $usedVariables = @($query.usedVariables | ForEach-Object { [string]$_ })
        }

        $lines.Add("- Query ID: $queryId")
        $lines.Add('')
        $lines.Add('### What this query does')
        $lines.Add('')

        $explanationSteps = Get-QueryExplanation -QueryText $queryText -UsedVariables $usedVariables
        foreach ($step in $explanationSteps) {
            $lines.Add("- $step")
        }

        $lines.Add('')
        $lines.Add('### KQL')
        $lines.Add('')
        $lines.Add('```kql')
        $lines.Add($queryText)
        $lines.Add('```')
        $lines.Add('')
    }

    Set-Content -Path $filePath -Value ($lines -join "`r`n") -Encoding utf8

    $sheetFiles.Add([PSCustomObject]@{
        order = $page.order
        name = $page.name
        file = $fileName
        path = $filePath
        tileCount = $pageTiles.Count
    })
}

foreach ($sheet in ($sheetFiles | Sort-Object order)) {
    $indexLines.Add("- $($sheet.order). [$($sheet.name)]($($sheet.file)) ($($sheet.tileCount) tiles)")
}

$indexLines.Add('')
$indexLines.Add('Generated by src/Build-DashboardKqlSheets.ps1 from dashboards/dashboard-FinOps-hub_2.json.')

Set-Content -Path (Join-Path $OutputRoot 'README.md') -Value ($indexLines -join "`r`n") -Encoding utf8

Write-Host "Generated $($sheetFiles.Count) sheet files in: $OutputRoot"