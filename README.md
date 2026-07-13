<div align="center">

# Wolf Security Writeups

Portafolio técnico de ciberseguridad con máquinas vulnerables, técnicas aplicadas y documentación práctica.

[![GitHub Pages](https://github.com/Gaabooox/Machines/actions/workflows/pages.yml/badge.svg)](https://github.com/Gaabooox/Machines/actions/workflows/pages.yml)
[![Website](https://img.shields.io/badge/website-online-76d88b?style=flat-square)](https://gaabooox.github.io/Machines/)
[![Made with MkDocs](https://img.shields.io/badge/MkDocs-Material-11171d?style=flat-square)](https://squidfunk.github.io/mkdocs-material/)

[Ver portafolio](https://gaabooox.github.io/Machines/) ·
[Explorar máquinas](https://gaabooox.github.io/Machines/machines/) ·
[Consultar técnicas](https://gaabooox.github.io/Machines/techniques/)

</div>

---

## Descripción

Este repositorio reúne writeups de laboratorios de ciberseguridad resueltos en distintas plataformas. Cada máquina documenta el proceso de reconocimiento, enumeración, explotación, escalada de privilegios y conclusiones.

El sitio genera automáticamente:

- Catálogo de máquinas.
- Índice de técnicas.
- Agrupación por plataformas.
- Línea temporal de progreso.
- Buscador global.
- Tema claro y oscuro.
- Metadatos SEO y Open Graph.
- Sitemap y página 404 personalizada.

## Estado del portafolio

<!-- PORTFOLIO_STATS_START -->
| Métrica | Total |
|---|---:|
| Máquinas | 7 |
| Plataformas | 2 |
| Técnicas | 13 |
<!-- PORTFOLIO_STATS_END -->

## Tecnologías

- MkDocs Material.
- Markdown.
- PowerShell.
- JavaScript.
- CSS.
- GitHub Actions.
- GitHub Pages.

## Estructura

```text
Machines/
├── docs/
│   ├── assets/
│   │   ├── data/
│   │   └── images/
│   ├── dockerlabs/
│   ├── machines/
│   ├── platforms/
│   ├── techniques/
│   ├── timeline/
│   ├── javascripts/
│   ├── stylesheets/
│   └── overrides/
├── scripts/
├── templates/
├── mkdocs.yml
└── README.md
```

## Ejecutar localmente

```powershell
git clone https://github.com/Gaabooox/Machines.git
cd Machines

python -m venv .venv
.\.venv\Scripts\Activate.ps1

python -m pip install --upgrade pip
pip install mkdocs-material

mkdocs serve
```

El sitio quedará disponible en la dirección mostrada por MkDocs.

## Agregar una máquina

```powershell
.\.venv\Scripts\Activate.ps1
.\scripts\nueva-maquina.ps1
```

El generador crea el writeup y actualiza automáticamente los datos utilizados por el catálogo, las técnicas, las plataformas, el progreso, la búsqueda y las estadísticas del README.

## Actualizar datos manualmente

```powershell
.\scripts\rebuild-site-data.ps1
```

## Compilar

```powershell
mkdocs build --strict
```

## Publicación

Los cambios enviados a la rama `main` se publican mediante GitHub Actions en GitHub Pages.

## Autor

**Gabriel Saavedra**  
Portafolio orientado a ciberseguridad práctica, aprendizaje continuo y documentación técnica.