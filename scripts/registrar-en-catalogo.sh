#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
JSON="$REPO_ROOT/docs/assets/data/machines.json"

NAME="$1"; SLUG="$2"; PLATFORM="$3"; PLATFORM_SLUG="$4"; DIFFICULTY="$5"; DIFF_SLUG="$6"; OS="$7"; SUMMARY="$8"; ACCESS="$9"; ESCALATION="${10}"; DATE="${11}"
shift 11
TAGS=()
while [ $# -gt 0 ]; do
    if [ "$1" = "-t" ]; then
        shift
        [ -n "$1" ] && TAGS+=("$1")
    fi
    shift
done

if [ -f "$JSON" ]; then
    # check duplicate
    if python3 -c "
import json,sys
with open(sys.argv[1],encoding='utf-8') as f:
    data=json.load(f)
for m in data:
    if m.get('slug')==sys.argv[2] and m.get('platformSlug')==sys.argv[3]:
        sys.exit(1)
sys.exit(0)
" "$JSON" "$SLUG" "$PLATFORM_SLUG"; then
        :
    else
        echo "La máquina ya existe en machines.json: $PLATFORM / $NAME" >&2
        exit 1
    fi
    # append
    python3 - "$JSON" "$NAME" "$SLUG" "$PLATFORM" "$PLATFORM_SLUG" "$DIFFICULTY" "$DIFF_SLUG" "$OS" "$SUMMARY" "$ACCESS" "$ESCALATION" "$DATE" "${TAGS[@]}" << 'PYEOF'
import json,sys,os
json_path=sys.argv[1]
with open(json_path,encoding='utf-8') as f:
    machines=json.load(f)
name=sys.argv[2]; slug=sys.argv[3]; platform=sys.argv[4]; pslug=sys.argv[5]
diff=sys.argv[6]; dslug=sys.argv[7]; os=sys.argv[8]
summary=sys.argv[9]; access=sys.argv[10]; esc=sys.argv[11]; date=sys.argv[12]
tags=sys.argv[13:]
newm={
  "name": name,
  "slug": slug,
  "platform": platform,
  "platformSlug": pslug,
  "difficulty": diff,
  "difficultySlug": dslug,
  "operatingSystem": os,
  "status": "Completada",
  "path": f"{pslug}/{dslug}/{slug}/",
  "summary": summary,
  "access": access,
  "escalation": esc,
  "date": date,
  "tags": tags
}
machines.append(newm)
with open(json_path,'w',encoding='utf-8') as f:
    json.dump(machines,f,ensure_ascii=False,indent=2)
PYEOF
else
    python3 - "$JSON" "$NAME" "$SLUG" "$PLATFORM" "$PLATFORM_SLUG" "$DIFFICULTY" "$DIFF_SLUG" "$OS" "$SUMMARY" "$ACCESS" "$ESCALATION" "$DATE" "${TAGS[@]}" << 'PYEOF'
import json,sys,os
json_path=sys.argv[1]
machines=[]
name=sys.argv[2]; slug=sys.argv[3]; platform=sys.argv[4]; pslug=sys.argv[5]
diff=sys.argv[6]; dslug=sys.argv[7]; os=sys.argv[8]
summary=sys.argv[9]; access=sys.argv[10]; esc=sys.argv[11]; date=sys.argv[12]
tags=sys.argv[13:]
newm={
  "name": name,
  "slug": slug,
  "platform": platform,
  "platformSlug": pslug,
  "difficulty": diff,
  "difficultySlug": dslug,
  "operatingSystem": os,
  "status": "Completada",
  "path": f"{pslug}/{dslug}/{slug}/",
  "summary": summary,
  "access": access,
  "escalation": esc,
  "date": date,
  "tags": tags
}
machines.append(newm)
os.makedirs(os.path.dirname(json_path), exist_ok=True)
with open(json_path,'w',encoding='utf-8') as f:
    json.dump(machines,f,ensure_ascii=False,indent=2)
PYEOF
fi

echo ""
echo "Máquina registrada en el catálogo:"
echo "$PLATFORM / $DIFFICULTY / $NAME"
