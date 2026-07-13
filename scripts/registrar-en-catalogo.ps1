param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Slug,

    [Parameter(Mandatory)]
    [string]$Platform,

    [Parameter(Mandatory)]
    [string]$PlatformSlug,

    [Parameter(Mandatory)]
    [string]$Difficulty,

    [Parameter(Mandatory)]
    [string]$DifficultySlug,

    [Parameter(Mandatory)]
    [string]$OperatingSystem,

    [string[]]$Tags = @()
)


Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"


$repositoryRoot = Split-Path -Parent $PSScriptRoot

$jsonPath = Join-Path `
    $repositoryRoot `
    "docs\assets\data\machines.json"

$jsonDirectory = Split-Path -Parent $jsonPath


New-Item `
    -ItemType Directory `
    -Force `
    -Path $jsonDirectory |
    Out-Null


if (Test-Path $jsonPath) {
    $jsonContent = Get-Content `
        -Path $jsonPath `
        -Raw `
        -Encoding utf8

    if ([string]::IsNullOrWhiteSpace($jsonContent)) {
        $machines = @()
    }
    else {
        $machines = @(
            $jsonContent | ConvertFrom-Json
        )
    }
}
else {
    $machines = @()
}


$existingMachine = $machines |
    Where-Object {
        $_.slug -eq $Slug -and
        $_.platformSlug -eq $PlatformSlug
    }


if ($existingMachine) {
    Write-Host ""
    Write-Host "La máquina ya existe en machines.json:"
    Write-Host "$Platform / $Name"
    exit 1
}


$newMachine = [PSCustomObject][ordered]@{
    name             = $Name
    slug             = $Slug
    platform         = $Platform
    platformSlug     = $PlatformSlug
    difficulty       = $Difficulty
    difficultySlug   = $DifficultySlug
    operatingSystem  = $OperatingSystem
    status           = "Completada"
    path             = "$PlatformSlug/$DifficultySlug/$Slug/"
    tags             = @($Tags)
}


$updatedMachines = @($machines) + $newMachine


$updatedMachines |
    ConvertTo-Json -Depth 6 |
    Set-Content `
        -Path $jsonPath `
        -Encoding utf8


Write-Host ""
Write-Host "Máquina agregada al catálogo:"
Write-Host "$Platform / $Difficulty / $Name"
Write-Host ""
Write-Host "Archivo actualizado:"
Write-Host $jsonPath