Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"


function Convert-ToSlug {
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

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
    $slug = $slug.Trim("-")

    return $slug
}


function Select-MenuOption {
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [array]$Options
    )

    while ($true) {
        Write-Host ""
        Write-Host $Title
        Write-Host "-------------------------------------"

        for ($index = 0; $index -lt $Options.Count; $index++) {
            $number = $index + 1
            Write-Host "$number) $($Options[$index].Name)"
        }

        Write-Host ""

        $selection = Read-Host "Opción"
        $selectedNumber = 0

        $isNumber = [int]::TryParse(
            $selection,
            [ref]$selectedNumber
        )

        if (
            $isNumber -and
            $selectedNumber -ge 1 -and
            $selectedNumber -le $Options.Count
        ) {
            return $Options[$selectedNumber - 1]
        }

        Write-Host ""
        Write-Host "Opción inválida. Elige uno de los números mostrados."
    }
}


$repositoryRoot = Split-Path -Parent $PSScriptRoot

$templatePath = Join-Path `
    $repositoryRoot `
    "templates\writeup-template.md"


if (-not (Test-Path $templatePath)) {
    Write-Host ""
    Write-Host "Error: no se encontró la plantilla:"
    Write-Host $templatePath
    exit 1
}


$platformOptions = @(
    [PSCustomObject]@{
        Name = "DockerLabs"
        Slug = "dockerlabs"
    }

    [PSCustomObject]@{
        Name = "Hack The Box"
        Slug = "hackthebox"
    }

    [PSCustomObject]@{
        Name = "TryHackMe"
        Slug = "tryhackme"
    }

    [PSCustomObject]@{
        Name = "VulnHub"
        Slug = "vulnhub"
    }

    [PSCustomObject]@{
        Name = "Otra plataforma"
        Slug = "custom"
    }
)


$difficultyOptions = @(
    [PSCustomObject]@{
        Name = "Very Easy"
        Slug = "very-easy"
    }

    [PSCustomObject]@{
        Name = "Easy"
        Slug = "easy"
    }

    [PSCustomObject]@{
        Name = "Medium"
        Slug = "medium"
    }

    [PSCustomObject]@{
        Name = "Hard"
        Slug = "hard"
    }

    [PSCustomObject]@{
        Name = "Insane"
        Slug = "insane"
    }

    [PSCustomObject]@{
        Name = "Otra dificultad"
        Slug = "custom"
    }
)


$operatingSystemOptions = @(
    [PSCustomObject]@{
        Name = "Linux"
        Slug = "linux"
    }

    [PSCustomObject]@{
        Name = "Windows"
        Slug = "windows"
    }

    [PSCustomObject]@{
        Name = "Otro sistema"
        Slug = "custom"
    }
)


Write-Host ""
Write-Host "====================================="
Write-Host " GENERADOR DE WRITEUPS"
Write-Host "====================================="
Write-Host ""


do {
    $machineName = Read-Host "Nombre de la máquina"

    if ([string]::IsNullOrWhiteSpace($machineName)) {
        Write-Host "El nombre de la máquina es obligatorio."
    }
}
while ([string]::IsNullOrWhiteSpace($machineName))


$platform = Select-MenuOption `
    -Title "Selecciona la plataforma" `
    -Options $platformOptions


if ($platform.Slug -eq "custom") {
    do {
        $customPlatform = Read-Host "Nombre de la plataforma"
    }
    while ([string]::IsNullOrWhiteSpace($customPlatform))

    $platform = [PSCustomObject]@{
        Name = $customPlatform
        Slug = Convert-ToSlug $customPlatform
    }
}


$difficulty = Select-MenuOption `
    -Title "Selecciona la dificultad" `
    -Options $difficultyOptions


if ($difficulty.Slug -eq "custom") {
    do {
        $customDifficulty = Read-Host "Nombre de la dificultad"
    }
    while ([string]::IsNullOrWhiteSpace($customDifficulty))

    $difficulty = [PSCustomObject]@{
        Name = $customDifficulty
        Slug = Convert-ToSlug $customDifficulty
    }
}


$operatingSystem = Select-MenuOption `
    -Title "Selecciona el sistema operativo" `
    -Options $operatingSystemOptions


if ($operatingSystem.Slug -eq "custom") {
    do {
        $customOperatingSystem = Read-Host "Nombre del sistema operativo"
    }
    while ([string]::IsNullOrWhiteSpace($customOperatingSystem))

    $operatingSystem = [PSCustomObject]@{
        Name = $customOperatingSystem
        Slug = Convert-ToSlug $customOperatingSystem
    }
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
    Write-Host ""
    Write-Host "Error: ya existe un writeup para esa máquina:"
    Write-Host $destinationFile
    exit 1
}


New-Item `
    -ItemType Directory `
    -Force `
    -Path $destinationDirectory |
    Out-Null


New-Item `
    -ItemType Directory `
    -Force `
    -Path $imagesDirectory |
    Out-Null


$content = Get-Content `
    -Path $templatePath `
    -Raw `
    -Encoding utf8


$content = $content.Replace(
    "NOMBRE_MAQUINA",
    $machineName
)

$content = $content.Replace(
    "PLATAFORMA",
    $platform.Name
)

$content = $content.Replace(
    "DIFICULTAD",
    $difficulty.Name
)

$content = $content.Replace(
    "SISTEMA_OPERATIVO",
    $operatingSystem.Name
)


Set-Content `
    -Path $destinationFile `
    -Value $content `
    -Encoding utf8


Write-Host ""
Write-Host "====================================="
Write-Host " WRITEUP CREADO"
Write-Host "====================================="
Write-Host ""
Write-Host "Máquina:     $machineName"
Write-Host "Plataforma:  $($platform.Name)"
Write-Host "Dificultad:  $($difficulty.Name)"
Write-Host "Sistema:     $($operatingSystem.Name)"
Write-Host ""
Write-Host "Archivo:"
Write-Host $destinationFile
Write-Host ""
Write-Host "Carpeta preparada para imágenes:"
Write-Host $imagesDirectory
Write-Host ""
Write-Host "Las capturas siguen marcadas como IMAGEN PENDIENTE."
Write-Host ""

notepad $destinationFile