#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$WebsiteId = "61b2738b-5ee7-45e2-acb0-dbeb0ed0c994"
$UmamiScriptUrl = "https://cloud.umami.is/script.js"
$TrackedDomain = "gaabooox.github.io"

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

$repositoryRoot = (Get-Location).Path
$mkdocsPath = Join-Path $repositoryRoot "mkdocs.yml"
$overridePath = Join-Path $repositoryRoot "docs\overrides\main.html"
$analyticsPath = Join-Path $repositoryRoot "docs\javascripts\analytics.js"

$requiredPaths = @(
    ".git",
    "mkdocs.yml",
    "docs"
)

foreach ($relativePath in $requiredPaths) {
    if (-not (Test-Path (Join-Path $repositoryRoot $relativePath))) {
        throw "Ejecuta este script desde la raíz del repositorio Machines."
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path `
    (Split-Path -Parent $repositoryRoot) `
    "Machines-umami-backup-$timestamp"

New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null

foreach ($relativePath in @(
    "mkdocs.yml",
    "docs\overrides\main.html",
    "docs\javascripts\analytics.js"
)) {
    $source = Join-Path $repositoryRoot $relativePath

    if (Test-Path $source) {
        $destination = Join-Path $backupRoot $relativePath
        $destinationParent = Split-Path -Parent $destination

        New-Item `
            -ItemType Directory `
            -Force `
            -Path $destinationParent |
            Out-Null

        Copy-Item `
            -Path $source `
            -Destination $destination `
            -Force
    }
}

$pythonCommand = $null

if (Test-Path (Join-Path $repositoryRoot ".venv\Scripts\python.exe")) {
    $pythonCommand = Join-Path $repositoryRoot ".venv\Scripts\python.exe"
}
elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCommand = "python"
}
elseif (Get-Command py -ErrorAction SilentlyContinue) {
    $pythonCommand = "py"
}
else {
    throw "No se encontró Python."
}

$pythonScriptPath = Join-Path $env:TEMP "fix-machines-umami.py"

$pythonScript = @'
from pathlib import Path
import sys
import yaml

repo = Path(sys.argv[1])
config_path = repo / "mkdocs.yml"

with config_path.open("r", encoding="utf-8") as fh:
    config = yaml.safe_load(fh) or {}

theme = config.get("theme")

if isinstance(theme, str):
    theme = {"name": theme}
elif not isinstance(theme, dict):
    theme = {"name": "material"}

theme.setdefault("name", "material")
theme["custom_dir"] = "docs/overrides"
config["theme"] = theme

extra_javascript = config.get("extra_javascript", [])

if not isinstance(extra_javascript, list):
    extra_javascript = []

config["extra_javascript"] = [
    item
    for item in extra_javascript
    if str(item).strip() != "javascripts/analytics.js"
]

with config_path.open("w", encoding="utf-8", newline="\n") as fh:
    yaml.safe_dump(
        config,
        fh,
        allow_unicode=True,
        sort_keys=False,
        default_flow_style=False,
        width=1000,
    )
'@

Write-Utf8File `
    -Path $pythonScriptPath `
    -Content $pythonScript

try {
    & $pythonCommand $pythonScriptPath $repositoryRoot

    if ($LASTEXITCODE -ne 0) {
        throw "No se pudo actualizar mkdocs.yml."
    }
}
finally {
    Remove-Item `
        -Path $pythonScriptPath `
        -Force `
        -ErrorAction SilentlyContinue
}

$trackerBlock = @"
  <!-- UMAMI_TRACKER_START -->
  <script
    defer
    src="$UmamiScriptUrl"
    data-website-id="$WebsiteId"
    data-host-url="https://cloud.umami.is"
    data-domains="$TrackedDomain"
    data-performance="true"
  ></script>
  <!-- UMAMI_TRACKER_END -->
"@

if (Test-Path $overridePath) {
    $override = Get-Content `
        -Path $overridePath `
        -Raw `
        -Encoding utf8
}
else {
    $override = @'
{% extends "base.html" %}

{% block extrahead %}
  {{ super() }}
{% endblock %}
'@
}

$trackerPattern =
    "(?s)\s*<!-- UMAMI_TRACKER_START -->.*?<!-- UMAMI_TRACKER_END -->\s*"

$override = [regex]::Replace(
    $override,
    $trackerPattern,
    "`r`n"
)

$extraHeadPattern =
    "(?s)(\{%\s*block\s+extrahead\s*%\})(.*?)(\{%\s*endblock\s*%\})"

$match = [regex]::Match($override, $extraHeadPattern)

if ($match.Success) {
    $blockStart = $match.Groups[1].Value
    $blockBody = $match.Groups[2].Value.TrimEnd()
    $blockEnd = $match.Groups[3].Value

    if ($blockBody -notmatch "\{\{\s*super\(\)\s*\}\}") {
        $blockBody = "`r`n  {{ super() }}`r`n" + $blockBody
    }

    $replacement =
        $blockStart +
        $blockBody +
        "`r`n`r`n" +
        $trackerBlock +
        "`r`n" +
        $blockEnd

    $override = $override.Remove(
        $match.Index,
        $match.Length
    ).Insert(
        $match.Index,
        $replacement
    )
}
else {
    $override = $override.TrimEnd() + @"

{% block extrahead %}
  {{ super() }}

$trackerBlock
{% endblock %}
"@
}

Write-Utf8File `
    -Path $overridePath `
    -Content $override

if (Test-Path $analyticsPath) {
    Remove-Item -Path $analyticsPath -Force
}

$mkdocsCommand = $null

if (Test-Path (Join-Path $repositoryRoot ".venv\Scripts\mkdocs.exe")) {
    $mkdocsCommand = Join-Path $repositoryRoot ".venv\Scripts\mkdocs.exe"
}
elseif (Get-Command mkdocs -ErrorAction SilentlyContinue) {
    $mkdocsCommand = "mkdocs"
}
else {
    throw "No se encontró MkDocs."
}

& $mkdocsCommand build --strict

if ($LASTEXITCODE -ne 0) {
    throw "MkDocs no pudo construir el sitio."
}

$builtIndex = Join-Path $repositoryRoot "site\index.html"

if (-not (Test-Path $builtIndex)) {
    throw "No se generó site\index.html."
}

$builtHtml = Get-Content `
    -Path $builtIndex `
    -Raw `
    -Encoding utf8

if (
    $builtHtml -notmatch [regex]::Escape($UmamiScriptUrl) -or
    $builtHtml -notmatch [regex]::Escape($WebsiteId)
) {
    throw "El tracker de Umami no quedó insertado en el HTML generado."
}

Write-Host ""
Write-Host "UMAMI CORREGIDO"
Write-Host ""
Write-Host "Tracker insertado directamente en <head>."
Write-Host "Dominio configurado: $TrackedDomain"
Write-Host "Website ID: $WebsiteId"
Write-Host ""
Write-Host "Ejecuta:"
Write-Host "git add -A"
Write-Host 'git commit -m "fix: corregir integracion de umami"'
Write-Host "git push origin main"
