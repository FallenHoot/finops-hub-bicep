<#
.SYNOPSIS
    Checks pinned AVM module versions in Bicep files against latest versions in MCR.

.DESCRIPTION
    Scans main.bicep and modules/*.bicep for br/public:avm/* module references,
    queries MCR tags for each module, and reports whether an update is available.

.PARAMETER Path
    Optional root path of the repo. Defaults to current directory.

.PARAMETER FailOnDrift
    Return exit code 1 when any module has a newer stable version available.

.EXAMPLE
    pwsh ./src/Test-AvmVersionDrift.ps1

.EXAMPLE
    pwsh ./src/Test-AvmVersionDrift.ps1 -FailOnDrift
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [switch]$FailOnDrift
)

$ErrorActionPreference = 'Stop'

function Get-StableMaxVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Tags
    )

    $stable = $Tags | Where-Object { $_ -match '^\d+\.\d+\.\d+$' }
    if (-not $stable) {
        return $null
    }

    return ($stable | Sort-Object { [version]$_ } -Descending | Select-Object -First 1)
}

$bicepFiles = @(
    Join-Path $Path 'main.bicep'
)

$moduleDir = Join-Path $Path 'modules'
if (Test-Path $moduleDir) {
    $bicepFiles += Get-ChildItem -Path $moduleDir -Filter *.bicep -Recurse | ForEach-Object { $_.FullName }
}

$refs = @()
$pattern = 'br/public:([^''"]+):([0-9]+\.[0-9]+\.[0-9]+)'

foreach ($file in $bicepFiles) {
    if (-not (Test-Path $file)) {
        continue
    }

    $content = Get-Content -Path $file -Raw
    $matches = [regex]::Matches($content, $pattern)
    foreach ($m in $matches) {
        $refs += [pscustomobject]@{
            File = $file
            ModulePath = $m.Groups[1].Value
            PinnedVersion = $m.Groups[2].Value
        }
    }
}

if (-not $refs) {
    Write-Host 'No AVM references found.'
    exit 0
}

$uniqueRefs = $refs |
    Group-Object -Property ModulePath |
    ForEach-Object {
        $sample = $_.Group | Select-Object -First 1
        [pscustomobject]@{
            ModulePath = $sample.ModulePath
            PinnedVersion = $sample.PinnedVersion
            Files = ($_.Group.File | ForEach-Object { Split-Path $_ -Leaf } | Sort-Object -Unique) -join ', '
        }
    } |
    Sort-Object ModulePath

$results = @()

foreach ($ref in $uniqueRefs) {
    $endpoint = "https://mcr.microsoft.com/v2/bicep/$($ref.ModulePath)/tags/list"
    $latest = $null
    $status = 'OK'
    $message = ''

    try {
        $resp = Invoke-RestMethod -Uri $endpoint -TimeoutSec 20
        $latest = Get-StableMaxVersion -Tags $resp.tags

        if (-not $latest) {
            $status = 'UNKNOWN'
            $message = 'No stable semantic tags found in MCR response.'
        }
    } catch {
        $status = 'ERROR'
        $message = $_.Exception.Message
    }

    $updateAvailable = $false
    if ($latest) {
        $updateAvailable = ([version]$latest -gt [version]$ref.PinnedVersion)
        if ($updateAvailable) {
            $status = 'UPDATE_AVAILABLE'
        }
    }

    $results += [pscustomobject]@{
        ModulePath = $ref.ModulePath
        PinnedVersion = $ref.PinnedVersion
        LatestStable = if ($latest) { $latest } else { '' }
        Status = $status
        Files = $ref.Files
        Note = $message
    }
}

$results | Format-Table -AutoSize

$updates = $results | Where-Object { $_.Status -eq 'UPDATE_AVAILABLE' }
$errors = $results | Where-Object { $_.Status -eq 'ERROR' }

Write-Host ''
Write-Host ("Modules scanned: {0}" -f $results.Count)
Write-Host ("Updates available: {0}" -f $updates.Count)
Write-Host ("Lookup errors: {0}" -f $errors.Count)

if ($FailOnDrift -and $updates.Count -gt 0) {
    Write-Error 'AVM version drift detected.'
    exit 1
}
