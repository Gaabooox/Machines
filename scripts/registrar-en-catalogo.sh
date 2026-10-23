#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
JSON="$REPO_ROOT/docs/assets/data/machines.json"

if [ "$#" -lt 11 ]; then
    echo "Uso: $0 Nombre Slug Plataforma PlatformSlug Dificultad DifficultySlug SO Resumen Acceso Escalada Fecha [tags...]" >&2
    exit 1
fi

NAME="$1"
SLUG="$2"
PLATFORM="$3"
PLATFORM_SLUG="$4"
DIFFICULTY="$5"
DIFFICULTY_SLUG="$6"
OPERATING_SYSTEM="$7"
SUMMARY="$8"
ACCESS="$9"
ESCALATION="${10}"
DATE="${11}"

shift 11
TAGS=("$@")

python3 - "$JSON" "$NAME" "$SLUG" "$PLATFORM" "$PLATFORM_SLUG" \
    "$DIFFICULTY" "$DIFFICULTY_SLUG" "$OPERATING_SYSTEM" \
    "$SUMMARY" "$ACCESS" "$ESCALATION" "$DATE" "${TAGS[@]}" << 'PY'
import json
import pathlib
import sys

(
    json_path,
    name,
    slug,
    platform,
    platform_slug,
    difficulty,
    difficulty_slug,
    operating_system,
    summary,
    access,
    escalation,
    date,
    *tags
) = sys.argv[1:]

path = pathlib.Path(json_path)

if path.exists():
    machines = json.loads(path.read_text(encoding="utf-8"))
else:
    machines = []

for machine in machines:
    if machine.get("slug") == slug and machine.get("platformSlug") == platform_slug:
        sys.exit(f"La máquina ya existe en machines.json: {platform} / {name}")

machines.append({
    "name": name,
    "slug": slug,
    "platform": platform,
    "platformSlug": platform_slug,
    "difficulty": difficulty,
    "difficultySlug": difficulty_slug,
    "operatingSystem": operating_system,
    "status": "Completada",
    "path": f"{platform_slug}/{difficulty_slug}/{slug}/",
    "summary": summary,
    "access": access,
    "escalation": escalation,
    "date": date,
    "tags": tags
})

path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(
    json.dumps(machines, ensure_ascii=False, indent=2),
    encoding="utf-8"
)
PY

echo ""
echo "Máquina registrada en el catálogo:"
echo "$PLATFORM / $DIFFICULTY / $NAME"
