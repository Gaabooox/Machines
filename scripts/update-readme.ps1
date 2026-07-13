#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Utf8File {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Content
    )

    [System.IO.File]::WriteAllText(
        $Path,
        $Content,
        [System.Text.UTF8Encoding]::new($false)
    )
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$readmePath = Join-Path $repositoryRoot "README.md"
$machinesPath = Join-Path `
    $repositoryRoot `
    "docs\assets\data\machines.json"

$techniquesPath = Join-Path `
    $repositoryRoot `
    "docs\assets\data\techniques.json"

if (-not (Test-Path $readmePath)) {
    exit 0
}

if (-not (Test-Path $machinesPath)) {
    exit 0
}

$machines = @(
    Get-Content `
        -Path $machinesPath `
        -Raw `
        -Encoding utf8 |
    ConvertFrom-Json
)

$platformCount = @(
    $machines |
    ForEach-Object {
        if ($_.platformSlug) {
            [string]$_.platformSlug
        }
        else {
            [string]$_.platform
        }
    } |
    Where-Object {
        -not [string]::IsNullOrWhiteSpace($_)
    } |
    Sort-Object -Unique
).Count

if (Test-Path $techniquesPath) {
    $techniqueCount = @(
        Get-Content `
            -Path $techniquesPath `
            -Raw `
            -Encoding utf8 |
        ConvertFrom-Json
    ).Count
}
else {
    $techniqueCount = @(
        $machines |
        ForEach-Object { @($_.tags) } |
        ForEach-Object { $_ } |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace(
                [string]$_
            )
        } |
        Sort-Object -Unique
    ).Count
}

$statsBlock = @"
<!-- PORTFOLIO_STATS_START -->
| Métrica | Total |
|---|---:|
| Máquinas | $($machines.Count) |
| Plataformas | $platformCount |
| Técnicas | $techniqueCount |
<!-- PORTFOLIO_STATS_END -->
"@

$readme = Get-Content `
    -Path $readmePath `
    -Raw `
    -Encoding utf8

$pattern =
    "(?s)<!-- PORTFOLIO_STATS_START -->.*?" +
    "<!-- PORTFOLIO_STATS_END -->"

if ([regex]::IsMatch($readme, $pattern)) {
    $readme = [regex]::Replace(
        $readme,
        $pattern,
        $statsBlock,
        1
    )
}
else {
    $readme = $readme.TrimEnd() +
        "`r`n`r`n" +
        $statsBlock +
        "`r`n"
}

Write-Utf8File `
    -Path $readmePath `
    -Content $readme