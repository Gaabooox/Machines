#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

TEMPLATE="$REPO_ROOT/templates/writeup-template.md"
REGISTRAR="$SCRIPT_DIR/registrar-en-catalogo.sh"

die() {
    echo "Error: $*" >&2
    exit 1
}

[ -f "$TEMPLATE" ] || die "no existe la plantilla: $TEMPLATE"
[ -f "$REGISTRAR" ] || die "no existe el registrador: $REGISTRAR"

read_required() {
    local prompt="$1"
    local value=""

    while [ -z "$value" ]; do
        printf '%s: ' "$prompt" >&2
        IFS= read -r value || die "entrada cancelada"
        [ -z "$value" ] && echo "Este campo es obligatorio." >&2
    done

    printf '%s' "$value"
}

select_menu() {
    local title="$1"
    shift
    local options=("$@")
    local selection index

    while true; do
        {
            echo
            echo "$title"
            echo "---------------------------------------------"
            index=1
            for option in "${options[@]}"; do
                echo "$index) $option"
                index=$((index + 1))
            done
            echo
        } >&2

        printf 'Opción: ' >&2
        IFS= read -r selection || die "entrada cancelada"

        if [[ "$selection" =~ ^[0-9]+$ ]] &&
            [ "$selection" -ge 1 ] &&
            [ "$selection" -le "${#options[@]}" ]; then
            printf '%s' "${options[$((selection - 1))]}"
            return
        fi

        echo "Opción inválida." >&2
    done
}

to_slug() {
    python3 - "$1" << 'PY'
import re
import sys
import unicodedata

value = unicodedata.normalize("NFD", sys.argv[1])
value = "".join(c for c in value if not unicodedata.combining(c))
print(re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-"))
PY
}

echo ""
echo "==============================================="
echo " GENERADOR DE WRITEUPS"
echo "==============================================="

MACHINE_NAME=$(read_required "Nombre de la máquina")

PLATFORM_OPTIONS=("DockerLabs" "Hack The Box" "TryHackMe" "VulnHub" "Otra plataforma")
DIFFICULTY_OPTIONS=("Very Easy" "Easy" "Medium" "Hard" "Insane" "Otra dificultad")
OS_OPTIONS=("Linux" "Windows" "Otro sistema")

PLATFORM_CHOICE=$(select_menu "Selecciona la plataforma" "${PLATFORM_OPTIONS[@]}")
DIFFICULTY_CHOICE=$(select_menu "Selecciona la dificultad" "${DIFFICULTY_OPTIONS[@]}")
OS_CHOICE=$(select_menu "Selecciona el sistema operativo" "${OS_OPTIONS[@]}")

case "$PLATFORM_CHOICE" in
    "DockerLabs") PLATFORM_NAME="DockerLabs"; PLATFORM_SLUG="dockerlabs" ;;
    "Hack The Box") PLATFORM_NAME="Hack The Box"; PLATFORM_SLUG="hackthebox" ;;
    "TryHackMe") PLATFORM_NAME="TryHackMe"; PLATFORM_SLUG="tryhackme" ;;
    "VulnHub") PLATFORM_NAME="VulnHub"; PLATFORM_SLUG="vulnhub" ;;
    *) PLATFORM_NAME=$(read_required "Nombre de la plataforma"); PLATFORM_SLUG=$(to_slug "$PLATFORM_NAME") ;;
esac

case "$DIFFICULTY_CHOICE" in
    "Very Easy") DIFFICULTY_NAME="Very Easy"; DIFFICULTY_SLUG="very-easy" ;;
    "Easy") DIFFICULTY_NAME="Easy"; DIFFICULTY_SLUG="easy" ;;
    "Medium") DIFFICULTY_NAME="Medium"; DIFFICULTY_SLUG="medium" ;;
    "Hard") DIFFICULTY_NAME="Hard"; DIFFICULTY_SLUG="hard" ;;
    "Insane") DIFFICULTY_NAME="Insane"; DIFFICULTY_SLUG="insane" ;;
    *) DIFFICULTY_NAME=$(read_required "Nombre de la dificultad"); DIFFICULTY_SLUG=$(to_slug "$DIFFICULTY_NAME") ;;
esac

case "$OS_CHOICE" in
    "Otro sistema") OS_NAME=$(read_required "Nombre del sistema operativo") ;;
    *) OS_NAME="$OS_CHOICE" ;;
esac

SUMMARY=$(read_required "Descripción corta de la máquina")
ACCESS=$(read_required "Método de acceso inicial")
ESCALATION=$(read_required "Método de escalada o 'No necesaria'")

printf 'Fecha de resolución (YYYY-MM-DD, Enter para hoy): ' >&2
IFS= read -r DATE_INPUT || die "entrada cancelada"
if [ -z "$DATE_INPUT" ]; then
    DATE=$(date +%Y-%m-%d)
else
    DATE="$DATE_INPUT"
fi

printf 'Técnicas separadas por comas (Nmap, SSH, Hydra): ' >&2
IFS= read -r TAGS_INPUT || die "entrada cancelada"

MACHINE_SLUG=$(to_slug "$MACHINE_NAME")
DEST_DIR="$REPO_ROOT/docs/$PLATFORM_SLUG/$DIFFICULTY_SLUG"
DEST_FILE="$DEST_DIR/$MACHINE_SLUG.md"
IMAGES_DIR="$REPO_ROOT/docs/assets/images/$PLATFORM_SLUG/$MACHINE_SLUG"

[ -f "$DEST_FILE" ] && die "ya existe el writeup: $DEST_FILE"

mkdir -p "$DEST_DIR" "$IMAGES_DIR"

TAGS=()
TAGS_PIPE=""

if [ -n "$TAGS_INPUT" ]; then
    IFS=',' read -ra RAW_TAGS <<< "$TAGS_INPUT"

    for tag in "${RAW_TAGS[@]}"; do
        tag="$(printf '%s' "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        [ -n "$tag" ] && TAGS+=("$tag")
    done

    TAGS_PIPE=$(IFS='|'; printf '%s' "${TAGS[*]}")
fi

python3 - "$TEMPLATE" "$DEST_FILE" \
    "$MACHINE_NAME" "$PLATFORM_NAME" "$DIFFICULTY_NAME" "$OS_NAME" \
    "$SUMMARY" "$ACCESS" "$ESCALATION" "$DATE" "$TAGS_PIPE" << 'PY'
import pathlib
import sys

template, destination, *values = sys.argv[1:]
keys = [
    "{{NAME}}",
    "{{PLATFORM}}",
    "{{DIFFICULTY}}",
    "{{OS}}",
    "{{SUMMARY}}",
    "{{ACCESS}}",
    "{{ESCALATION}}",
    "{{DATE}}",
    "{{TECHNIQUES_PIPE}}"
]

content = pathlib.Path(template).read_text(encoding="utf-8")

for key, value in zip(keys, values):
    content = content.replace(key, value)

pathlib.Path(destination).write_text(content, encoding="utf-8")
PY

bash "$REGISTRAR" \
    "$MACHINE_NAME" \
    "$MACHINE_SLUG" \
    "$PLATFORM_NAME" \
    "$PLATFORM_SLUG" \
    "$DIFFICULTY_NAME" \
    "$DIFFICULTY_SLUG" \
    "$OS_NAME" \
    "$SUMMARY" \
    "$ACCESS" \
    "$ESCALATION" \
    "$DATE" \
    "${TAGS[@]}"

echo ""
echo "==============================================="
echo " WRITEUP CREADO"
echo "==============================================="
echo "Archivo:  $DEST_FILE"
echo "Imágenes: $IMAGES_DIR"
echo ""

bash "$SCRIPT_DIR/rebuild_site_data.sh"

echo "Edita el writeup cuando quieras:"
echo "$DEST_FILE"
