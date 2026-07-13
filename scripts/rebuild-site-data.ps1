#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Utf8File {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Content
    )

    $parent = Split-Path -Parent $Path

    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    [System.IO.File]::WriteAllText(
        $Path,
        $Content,
        [System.Text.UTF8Encoding]::new($false)
    )
}

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

    $clean = (-join $characters).Normalize(
        [System.Text.NormalizationForm]::FormC
    )

    $slug = $clean.ToLowerInvariant()
    $slug = $slug -replace "[^a-z0-9]+", "-"
    return $slug.Trim("-")
}

function Get-PropertyValue {
    param(
        [Parameter(Mandatory)]$Object,
        [Parameter(Mandatory)][string]$Name,
        $Default = ""
    )

    $property = $Object.PSObject.Properties[$Name]

    if ($null -eq $property -or $null -eq $property.Value) {
        return $Default
    }

    if (
        $property.Value -is [string] -and
        [string]::IsNullOrWhiteSpace($property.Value)
    ) {
        return $Default
    }

    return $property.Value
}

function Get-MachineDate {
    param(
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [Parameter(Mandatory)][string]$RelativeWriteupPath,
        [Parameter(Mandatory)][string]$AbsoluteWriteupPath,
        [string]$ExistingDate
    )

    if (-not [string]::IsNullOrWhiteSpace($ExistingDate)) {
        return $ExistingDate
    }

    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitDates = @(
            & git `
                -C $RepositoryRoot `
                log `
                --follow `
                --format=%cs `
                -- $RelativeWriteupPath 2>$null |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }
        )

        if (
            $LASTEXITCODE -eq 0 -and
            $gitDates.Count -gt 0
        ) {
            return ([string]$gitDates[-1]).Trim()
        }
    }

    if (Test-Path $AbsoluteWriteupPath) {
        return (Get-Item $AbsoluteWriteupPath).LastWriteTime.ToString("yyyy-MM-dd")
    }

    return (Get-Date).ToString("yyyy-MM-dd")
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$jsonPath = Join-Path $repositoryRoot "docs\assets\data\machines.json"

if (-not (Test-Path $jsonPath)) {
    throw "No existe: $jsonPath"
}

$machines = @(
    Get-Content -Path $jsonPath -Raw -Encoding utf8 |
    ConvertFrom-Json
)

$normalizedMachines = foreach ($machine in $machines) {
    $platformSlug = [string](Get-PropertyValue $machine "platformSlug")
    $difficultySlug = [string](Get-PropertyValue $machine "difficultySlug")
    $slug = [string](Get-PropertyValue $machine "slug")

    $relativeWriteupPath = (
        "docs/$platformSlug/$difficultySlug/$slug.md"
    )

    $absoluteWriteupPath = Join-Path `
        $repositoryRoot `
        ($relativeWriteupPath -replace "/", "\")

    $resolvedDate = Get-MachineDate `
        -RepositoryRoot $repositoryRoot `
        -RelativeWriteupPath $relativeWriteupPath `
        -AbsoluteWriteupPath $absoluteWriteupPath `
        -ExistingDate ([string](Get-PropertyValue $machine "date"))

    [PSCustomObject][ordered]@{
        name = [string](Get-PropertyValue $machine "name")
        slug = $slug
        platform = [string](Get-PropertyValue $machine "platform")
        platformSlug = $platformSlug
        difficulty = [string](Get-PropertyValue $machine "difficulty")
        difficultySlug = $difficultySlug
        operatingSystem = [string](Get-PropertyValue $machine "operatingSystem")
        status = [string](Get-PropertyValue $machine "status" "Completada")
        path = [string](Get-PropertyValue $machine "path")
        summary = [string](Get-PropertyValue $machine "summary")
        access = [string](Get-PropertyValue $machine "access")
        escalation = [string](Get-PropertyValue $machine "escalation")
        date = $resolvedDate
        tags = @(
            Get-PropertyValue $machine "tags" @()
        )
    }
}

Write-Utf8File `
    -Path $jsonPath `
    -Content (
        $normalizedMachines |
        ConvertTo-Json -Depth 8
    )

$techniqueMap = @{}

foreach ($machine in $normalizedMachines) {
    foreach ($tagValue in @($machine.tags)) {
        $tag = ([string]$tagValue).Trim()

        if ([string]::IsNullOrWhiteSpace($tag)) {
            continue
        }

        $key = $tag.ToLowerInvariant()

        if (-not $techniqueMap.ContainsKey($key)) {
            $techniqueMap[$key] = [ordered]@{
                name = $tag
                slug = Convert-ToSlug $tag
                count = 0
                machines = [System.Collections.Generic.List[object]]::new()
            }
        }

        $techniqueMap[$key].count += 1
        $techniqueMap[$key].machines.Add(
            [PSCustomObject][ordered]@{
                name = $machine.name
                path = $machine.path
                platform = $machine.platform
                difficulty = $machine.difficulty
                operatingSystem = $machine.operatingSystem
                date = $machine.date
            }
        )
    }
}

$techniques = @(
    $techniqueMap.Values |
    ForEach-Object {
        [PSCustomObject][ordered]@{
            name = $_.name
            slug = $_.slug
            count = $_.count
            machines = @(
                $_.machines |
                Sort-Object name
            )
        }
    } |
    Sort-Object @{ Expression = "count"; Descending = $true }, name
)

$techniquesPath = Join-Path `
    $repositoryRoot `
    "docs\assets\data\techniques.json"

Write-Utf8File `
    -Path $techniquesPath `
    -Content (
        $techniques |
        ConvertTo-Json -Depth 8
    )

$timeline = @(
    $normalizedMachines |
    Sort-Object `
        @{ Expression = {
            try {
                [datetime]::ParseExact(
                    $_.date,
                    "yyyy-MM-dd",
                    [System.Globalization.CultureInfo]::InvariantCulture
                )
            }
            catch {
                [datetime]::MinValue
            }
        }; Descending = $true },
        @{ Expression = "name"; Descending = $false } |
    ForEach-Object {
        [PSCustomObject][ordered]@{
            name = $_.name
            slug = $_.slug
            path = $_.path
            platform = $_.platform
            difficulty = $_.difficulty
            operatingSystem = $_.operatingSystem
            summary = $_.summary
            date = $_.date
            year = if ($_.date -match "^(\d{4})") {
                $Matches[1]
            }
            else {
                "Sin fecha"
            }
            tags = @($_.tags)
        }
    }
)

$timelinePath = Join-Path `
    $repositoryRoot `
    "docs\assets\data\timeline.json"

Write-Utf8File `
    -Path $timelinePath `
    -Content (
        $timeline |
        ConvertTo-Json -Depth 8
    )

$searchEntries = [System.Collections.Generic.List[object]]::new()

foreach ($machine in $normalizedMachines) {
    $searchEntries.Add(
        [PSCustomObject][ordered]@{
            type = "machine"
            title = $machine.name
            url = $machine.path
            subtitle = "$($machine.platform) · $($machine.difficulty) · $($machine.operatingSystem)"
            content = $machine.summary
            keywords = @(
                $machine.platform,
                $machine.difficulty,
                $machine.operatingSystem,
                $machine.access,
                $machine.escalation,
                $machine.tags
            ) -join " "
        }
    )
}

foreach ($technique in $techniques) {
    $machineNames = @(
        $technique.machines |
        ForEach-Object { $_.name }
    )

    $searchEntries.Add(
        [PSCustomObject][ordered]@{
            type = "technique"
            title = $technique.name
            url = "techniques/#$($technique.slug)"
            subtitle = "$($technique.count) máquina(s)"
            content = "Utilizada en: $($machineNames -join ', ')"
            keywords = $machineNames -join " "
        }
    )
}

foreach ($machine in $normalizedMachines) {
    $writeupPath = Join-Path `
        $repositoryRoot `
        "docs\$($machine.platformSlug)\$($machine.difficultySlug)\$($machine.slug).md"

    if (-not (Test-Path $writeupPath)) {
        continue
    }

    $lines = Get-Content -Path $writeupPath -Encoding utf8
    $insideCode = $false
    $codeLanguage = ""
    $codeLines = [System.Collections.Generic.List[string]]::new()
    $currentAnchor = ""
    $currentHeading = $machine.name

    foreach ($line in $lines) {
        if (-not $insideCode -and $line -match "^(#{2,3})\s+(.+?)\s*$") {
            $currentHeading = $Matches[2].Trim()
            $currentAnchor = Convert-ToSlug $currentHeading
            continue
        }

        if (-not $insideCode -and $line -match "^```([A-Za-z0-9_-]*)\s*$") {
            $insideCode = $true
            $codeLanguage = $Matches[1].ToLowerInvariant()
            $codeLines.Clear()
            continue
        }

        if ($insideCode -and $line -match "^```\s*$") {
            $insideCode = $false

            $allowedLanguages = @(
                "",
                "bash",
                "shell",
                "sh",
                "zsh",
                "powershell",
                "pwsh",
                "python",
                "ruby",
                "vim"
            )

            if (
                $allowedLanguages -contains $codeLanguage -and
                $codeLines.Count -gt 0
            ) {
                $codeContent = ($codeLines -join "`n").Trim()

                if (-not [string]::IsNullOrWhiteSpace($codeContent)) {
                    $firstCommand = @(
                        $codeLines |
                        Where-Object {
                            -not [string]::IsNullOrWhiteSpace($_)
                        }
                    ) | Select-Object -First 1

                    $title = if ($firstCommand) {
                        ([string]$firstCommand).Trim()
                    }
                    else {
                        "Comando"
                    }

                    if ($title.Length -gt 72) {
                        $title = $title.Substring(0, 69) + "..."
                    }

                    $url = $machine.path

                    if (-not [string]::IsNullOrWhiteSpace($currentAnchor)) {
                        $url += "#$currentAnchor"
                    }

                    $searchEntries.Add(
                        [PSCustomObject][ordered]@{
                            type = "command"
                            title = $title
                            url = $url
                            subtitle = "$($machine.name) · $currentHeading"
                            content = $codeContent
                            keywords = "$($machine.name) $($machine.platform) $codeLanguage"
                        }
                    )
                }
            }

            $codeLines.Clear()
            $codeLanguage = ""
            continue
        }

        if ($insideCode) {
            $codeLines.Add($line)
        }
    }
}

$searchPath = Join-Path `
    $repositoryRoot `
    "docs\assets\data\search-index.json"

Write-Utf8File `
    -Path $searchPath `
    -Content (
        $searchEntries |
        ConvertTo-Json -Depth 8
    )

Write-Host "Datos regenerados:"
Write-Host "- Máquinas: $($normalizedMachines.Count)"
Write-Host "- Técnicas: $($techniques.Count)"
Write-Host "- Entradas de búsqueda: $($searchEntries.Count)"
Write-Host "- Línea temporal: $($timeline.Count)"