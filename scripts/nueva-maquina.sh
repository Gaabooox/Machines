#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

TEMPLATE="$REPO_ROOT/templates/writeup-template.md"
REGISTRAR="$SCRIPT_DIR/registrar-en-catalogo.sh"

[ -f "$TEMPLATE" ] || { echo "No existe la plantilla: $TEMPLATE"; exit 1; }
[ -f "$REGISTRAR" ] || { echo "No existe el registrador: $REGISTRAR"; exit 1; }

read_required() {
    local prompt="$1"
    local val=""
    while [ -z "$val" ]; do
        read -r -p "$prompt: " val
        [ -z "$val" ] && echo "Este campo es obligatorio."
    done
    echo "$val"
}

select_menu() {
    local title="$1"
    shift
    local options=("$@")
    while true; do
        echo ""
        echo "$title"
        echo "---------------------------------------------"
        local i=1
        for o in "${options[@]}"; do
            echo "$i) $o"
            ((i++))
        done
        echo ""
        read -r -p "Opción: " sel
        if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#options[@]}" ]; then
            echo "${options[$((sel-1))]}"
            return
        fi
        echo "Opción inválida."
    done
}

to_slug() {
    python3 -c "import sys,re; t=sys.argv[1].lower(); t=re.sub(r'[^a-z0-9]+','-',t); print(t.strip('-'))" "$1"
}

echo ""
echo "==============================================="
echo " GENERADOR DE WRITEUPS"
echo "==============================================="

MACHINE_NAME=$(read_required "Nombre de la máquina")

PLATFORM_OPTIONS=("DockerLabs" "Hack The Box" "TryHackMe" "VulnHub" "Otra plataforma")
DIFF_OPTIONS=("Very Easy" "Easy" "Medium" "Hard" "Insane" "Otra dificultad")
OS_OPTIONS=("Linux" "Windows" "Otro sistema")

PLATFORM_CHOICE=$(select_menu "Selecciona la plataforma" "${PLATFORM_OPTIONS[@]}")
DIFF_CHOICE=$(select_menu "Selecciona la dificultad" "${DIFF_OPTIONS[@]}")
OS_CHOICE=$(select_menu "Selecciona el sistema operativo" "${OS_OPTIONS[@]}")

case "$PLATFORM_CHOICE" in
    "Otra plataforma") PLATFORM_NAME=$(read_required "Nombre de la plataforma"); PLATFORM_SLUG=$(to_slug "$PLATFORM_NAME");;
    "DockerLabs") PLATFORM_NAME="DockerLabs"; PLATFORM_SLUG="dockerlabs";;
    "Hack The Box") PLATFORM_NAME="Hack The Box"; PLATFORM_SLUG="hackthebox";;
    "TryHackMe") PLATFORM_NAME="TryHackMe"; PLATFORM_SLUG="tryhackme";;
    "VulnHub") PLATFORM_NAME="VulnHub"; PLATFORM_SLUG="vulnhub";;
    *) PLATFORM_NAME="$PLATFORM_CHOICE"; PLATFORM_SLUG=$(to_slug "$PLATFORM_NAME");;
esac

case "$DIFF_CHOICE" in
    "Otra dificultad") DIFF_NAME=$(read_required "Nombre de la dificultad"); DIFF_SLUG=$(to_slug "$DIFF_NAME");;
    "Very Easy") DIFF_NAME="Very Easy"; DIFF_SLUG="very-easy";;
    "Easy") DIFF_NAME="Easy"; DIFF_SLUG="easy";;
    "Medium") DIFF_NAME="Medium"; DIFF_SLUG="medium";;
    "Hard") DIFF_NAME="Hard"; DIFF_SLUG="hard";;
    "Insane") DIFF_NAME="Insane"; DIFF_SLUG="insane";;
    *) DIFF_NAME="$DIFF_CHOICE"; DIFF_SLUG=$(to_slug "$DIFF_NAME");;
esac

case "$OS_CHOICE" in
    "Otro sistema") OS_NAME=$(read_required "Nombre del sistema operativo");;
    *) OS_NAME="$OS_CHOICE";;
esac

SUMMARY=$(read_required "Descripción corta de la máquina")
ACCESS=$(read_required "Método de acceso inicial")
ESCALATION=$(read_required "Método de escalada o 'No necesaria'")

read -r -p "Fecha de resolución (YYYY-MM-DD, Enter para hoy): " DATE_INPUT
if [ -z "$DATE_INPUT" ]; then
    DATE=$(date +%Y-%m-%d)
else
    DATE="$DATE_INPUT"
fi

read -r -p "Técnicas separadas por comas (Nmap, SSH, Hydra): " TAGS_INPUT

MACHINE_SLUG=$(to_slug "$MACHINE_NAME")
DEST_DIR="$REPO_ROOT/docs/$PLATFORM_SLUG/$DIFF_SLUG"
DEST_FILE="$DEST_DIR/$MACHINE_SLUG.md"
IMAGES_DIR="$REPO_ROOT/docs/assets/images/$PLATFORM_SLUG/$MACHINE_SLUG"

[ -f "$DEST_FILE" ] && { echo "Ya existe el writeup: $DEST_FILE"; exit 1; }

mkdir -p "$DEST_DIR" "$IMAGES_DIR"

CONTENT=$(cat "$TEMPLATE")
CONTENT=$(echo "$CONTENT" | sed "s|{{NAME}}|$MACHINE_NAME|g")
CONTENT=$(echo "$CONTENT" | sed "s|{{PLATFORM}}|$PLATFORM_NAME|g")
CONTENT=$(echo "$CONTENT" | sed "s|{{DIFFICULTY}}|$DIFF_NAME|g")
CONTENT=$(echo "$CONTENT" | sed "s|{{OS}}|$OS_NAME|g")
CONTENT=$(echo "$CONTENT" | sed "s|{{SUMMARY}}|$SUMMARY|g")
CONTENT=$(echo "$CONTENT" | sed "s|{{ACCESS}}|$ACCESS|g")
CONTENT=$(echo "$CONTENT" | sed "s|{{ESCALATION}}|$ESCALATION|g")
CONTENT=$(echo "$CONTENT" | sed "s|{{DATE}}|$DATE|g")

if [ -z "$TAGS_INPUT" ]; then
    TAGS_PIPE=""
    TAGS_ARR=()
else
    TAGS_PIPE=$(echo "$TAGS_INPUT" | tr ',' '|' | sed 's/ |/|/g; s/| /|/g')
    IFS=',' read -ra TAGS_ARR <<< "$TAGS_INPUT"
    for i in "${!TAGS_ARR[@]}"; do
        TAGS_ARR[$i]=$(echo "${TAGS_ARR[$i]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    done
fi

CONTENT=$(echo "$CONTENT" | sed "s|{{TECHNIQUES_PIPE}}|$TAGS_PIPE|g")
printf "%s" "$CONTENT" > "$DEST_FILE"

# build tags args
TAGS_ARGS=()
for t in "${TAGS_ARR[@]}"; do
    [ -n "$t" ] && TAGS_ARGS+=("-t" "$t")
done

bash "$REGISTRAR" "$MACHINE_NAME" "$MACHINE_SLUG" "$PLATFORM_NAME" "$PLATFORM_SLUG" "$DIFF_NAME" "$DIFF_SLUG" "$OS_NAME" "$SUMMARY" "$ACCESS" "$ESCALATION" "$DATE" "${TAGS_ARGS[@]}"

echo ""
echo "==============================================="
echo " WRITEUP CREADO"
echo "==============================================="
echo "Archivo:  $DEST_FILE"
echo "Imágenes: $IMAGES_DIR"
echo ""

if [ -f "$SCRIPT_DIR/rebuild_site_data.sh" ]; then
    bash "$SCRIPT_DIR/rebuild_site_data.sh"
elif [ -f "$SCRIPT_DIR/rebuild_site_data.py" ]; then
    python3 "$SCRIPT_DIR/rebuild_site_data.py"
fi

echo "Edita el writeup cuando quieras:"
echo "$DEST_FILE"
