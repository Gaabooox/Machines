Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Convert-ToSlug {
    param([Parameter(Mandatory)][string]$Text)

    $normalized = $Text.Normalize(
        [System.Text.NormalizationForm]::FormD
    )

    $characters = foreach ($character in $normalized.ToCharArray()) {
        $category =
            [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory(
                $character
            )

        if (
            $category -ne
            [System.Globalization.UnicodeCategory]::NonSpacingMark
        ) {
            $character
        }
    }

    $cleanText = (-join $characters).Normalize(
        [System.Text.NormalizationForm]::FormC
    )

    $slug = $cleanText.ToLowerInvariant()
    $slug = $slug -replace "[^a-z0-9]+", "-"
    return $slug.Trim("-")
}

function Select-MenuOption {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][array]$Options
    )

    while ($true) {
        Write-Host ""
        Write-Host $Title
        Write-Host ("-" * 45)

        for ($index = 0; $index -lt $Options.Count; $index++) {
            Write-Host "$($index + 1)) $($Options[$index].Name)"
        }

        Write-Host ""
        $selection = Read-Host "Opción"
        $selectedNumber = 0

        if (
            [int]::TryParse($selection, [ref]$selectedNumber) -and
            $selectedNumber -ge 1 -and
            $selectedNumber -le $Options.Count
        ) {
            return $Options[$selectedNumber - 1]
        }

        Write-Host "Opción inválida."
    }
}

function Read-RequiredValue {
    param([Parameter(Mandatory)][string]$Prompt)

    do {
        $value = Read-Host $Prompt

        if ([string]::IsNullOrWhiteSpace($value)) {
            Write-Host "Este campo es obligatorio."
        }
    }
    while ([string]::IsNullOrWhiteSpace($value))

    return $value.Trim()
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $repositoryRoot "templates\writeup-template.md"
$registrarPath = Join-Path $PSScriptRoot "registrar-en-catalogo.ps1"

if (-not (Test-Path $templatePath)) {
    throw "No existe la plantilla: $templatePath"
}

if (-not (Test-Path $registrarPath)) {
    throw "No existe el registrador: $registrarPath"
}

$platformOptions = @(
    [PSCustomObject]@{ Name = "DockerLabs"; Slug = "dockerlabs" }
    [PSCustomObject]@{ Name = "Hack The Box"; Slug = "hackthebox" }
    [PSCustomObject]@{ Name = "TryHackMe"; Slug = "tryhackme" }
    [PSCustomObject]@{ Name = "VulnHub"; Slug = "vulnhub" }
    [PSCustomObject]@{ Name = "Otra plataforma"; Slug = "custom" }
)

$difficultyOptions = @(
    [PSCustomObject]@{ Name = "Very Easy"; Slug = "very-easy" }
    [PSCustomObject]@{ Name = "Easy"; Slug = "easy" }
    [PSCustomObject]@{ Name = "Medium"; Slug = "medium" }
    [PSCustomObject]@{ Name = "Hard"; Slug = "hard" }
    [PSCustomObject]@{ Name = "Insane"; Slug = "insane" }
    [PSCustomObject]@{ Name = "Otra dificultad"; Slug = "custom" }
)

$osOptions = @(
    [PSCustomObject]@{ Name = "Linux"; Slug = "linux" }
    [PSCustomObject]@{ Name = "Windows"; Slug = "windows" }
    [PSCustomObject]@{ Name = "Otro sistema"; Slug = "custom" }
)

Write-Host ""
Write-Host "==============================================="
Write-Host " GENERADOR DE WRITEUPS"
Write-Host "==============================================="

$machineName = Read-RequiredValue "Nombre de la máquina"
$platform = Select-MenuOption "Selecciona la plataforma" $platformOptions
$difficulty = Select-MenuOption "Selecciona la dificultad" $difficultyOptions
$operatingSystem = Select-MenuOption "Selecciona el sistema operativo" $osOptions

if ($platform.Slug -eq "custom") {
    $customValue = Read-RequiredValue "Nombre de la plataforma"
    $platform = [PSCustomObject]@{
        Name = $customValue
        Slug = Convert-ToSlug $customValue
    }
}

if ($difficulty.Slug -eq "custom") {
    $customValue = Read-RequiredValue "Nombre de la dificultad"
    $difficulty = [PSCustomObject]@{
        Name = $customValue
        Slug = Convert-ToSlug $customValue
    }
}

if ($operatingSystem.Slug -eq "custom") {
    $customValue = Read-RequiredValue "Nombre del sistema operativo"
    $operatingSystem = [PSCustomObject]@{
        Name = $customValue
        Slug = Convert-ToSlug $customValue
    }
}

$summary = Read-RequiredValue "Descripción corta de la máquina"
$access = Read-RequiredValue "Método de acceso inicial"
$escalation = Read-RequiredValue "Método de escalada o 'No necesaria'"

$dateInput = Read-Host "Fecha de resolución (YYYY-MM-DD, Enter para hoy)"
$date = if ([string]::IsNullOrWhiteSpace($dateInput)) {
    Get-Date -Format "yyyy-MM-dd"
}
else {
    $dateInput.Trim()
}

$tagsInput = Read-Host "Técnicas separadas por comas (Nmap, SSH, Hydra)"

$tags = if ([string]::IsNullOrWhiteSpace($tagsInput)) {
    @()
}
else {
    @(
        $tagsInput -split "," |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
}

$machineSlug = Convert-ToSlug $machineName
$destinationDirectory = Join-Path `
    $repositoryRoot `
    "docs\$($platform.Slug)\$($difficulty.Slug)"

$destinationFile = Join-Path `
    $destinationDirectory `
    "$machineSlug.md"

$imagesDirectory = Join-Path `
    $repositoryRoot `
    "docs\assets\images\$($platform.Slug)\$machineSlug"

if (Test-Path $destinationFile) {
    throw "Ya existe el writeup: $destinationFile"
}

New-Item -ItemType Directory -Force -Path $destinationDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $imagesDirectory | Out-Null

$content = Get-Content -Path $templatePath -Raw -Encoding utf8

$replacements = [ordered]@{
    "{{NAME}}" = $machineName
    "{{PLATFORM}}" = $platform.Name
    "{{DIFFICULTY}}" = $difficulty.Name
    "{{OS}}" = $operatingSystem.Name
    "{{SUMMARY}}" = $summary
    "{{ACCESS}}" = $access
    "{{ESCALATION}}" = $escalation
    "{{DATE}}" = $date
    "{{TECHNIQUES_PIPE}}" = ($tags -join "|")
}

foreach ($item in $replacements.GetEnumerator()) {
    $content = $content.Replace($item.Key, $item.Value)
}

[System.IO.File]::WriteAllText(
    $destinationFile,
    $content,
    [System.Text.UTF8Encoding]::new($false)
)

& $registrarPath `
    -Name $machineName `
    -Slug $machineSlug `
    -Platform $platform.Name `
    -PlatformSlug $platform.Slug `
    -Difficulty $difficulty.Name `
    -DifficultySlug $difficulty.Slug `
    -OperatingSystem $operatingSystem.Name `
    -Summary $summary `
    -Access $access `
    -Escalation $escalation `
    -Date $date `
    -Tags $tags

Write-Host ""
Write-Host "==============================================="
Write-Host " WRITEUP CREADO"
Write-Host "==============================================="
Write-Host "Archivo:  $destinationFile"
Write-Host "Imágenes: $imagesDirectory"
Write-Host ""


$rebuildDataScript = Join-Path `
    $PSScriptRoot `
    "rebuild-site-data.ps1"

if (Test-Path $rebuildDataScript) {
    & $rebuildDataScript
}

notepad $destinationFile