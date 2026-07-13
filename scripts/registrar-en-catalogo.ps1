param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$Slug,
    [Parameter(Mandatory)][string]$Platform,
    [Parameter(Mandatory)][string]$PlatformSlug,
    [Parameter(Mandatory)][string]$Difficulty,
    [Parameter(Mandatory)][string]$DifficultySlug,
    [Parameter(Mandatory)][string]$OperatingSystem,
    [Parameter(Mandatory)][string]$Summary,
    [Parameter(Mandatory)][string]$Access,
    [Parameter(Mandatory)][string]$Escalation,
    [Parameter(Mandatory)][string]$Date,
    [string[]]$Tags = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$jsonPath = Join-Path $repositoryRoot "docs\assets\data\machines.json"

if (Test-Path $jsonPath) {
    $machines = @(
        Get-Content -Path $jsonPath -Raw -Encoding utf8 |
        ConvertFrom-Json
    )
}
else {
    $machines = @()
}

$duplicate = $machines |
    Where-Object {
        $_.slug -eq $Slug -and
        $_.platformSlug -eq $PlatformSlug
    }

if ($duplicate) {
    throw "La máquina ya existe en machines.json: $Platform / $Name"
}

$newMachine = [PSCustomObject][ordered]@{
    name = $Name
    slug = $Slug
    platform = $Platform
    platformSlug = $PlatformSlug
    difficulty = $Difficulty
    difficultySlug = $DifficultySlug
    operatingSystem = $OperatingSystem
    status = "Completada"
    path = "$PlatformSlug/$DifficultySlug/$Slug/"
    summary = $Summary
    access = $Access
    escalation = $Escalation
    date = $Date
    tags = @($Tags)
}

$updatedMachines = @($machines) + $newMachine

[System.IO.File]::WriteAllText(
    $jsonPath,
    ($updatedMachines | ConvertTo-Json -Depth 8),
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host ""
Write-Host "Máquina registrada en el catálogo:"
Write-Host "$Platform / $Difficulty / $Name"