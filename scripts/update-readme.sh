#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

README="$REPO_ROOT/README.md"
MACHINES="$REPO_ROOT/docs/assets/data/machines.json"
TECHNIQUES="$REPO_ROOT/docs/assets/data/techniques.json"

[ -f "$README" ] || exit 0
[ -f "$MACHINES" ] || exit 0

python3 - "$README" "$MACHINES" "$TECHNIQUES" << 'PY'
import json
import pathlib
import re
import sys

readme_path = pathlib.Path(sys.argv[1])
machines_path = pathlib.Path(sys.argv[2])
techniques_path = pathlib.Path(sys.argv[3])

machines = json.loads(machines_path.read_text(encoding="utf-8"))

platforms = {
    str(machine.get("platformSlug") or machine.get("platform") or "").strip()
    for machine in machines
}
platforms.discard("")

if techniques_path.exists():
    techniques = json.loads(techniques_path.read_text(encoding="utf-8"))
    technique_count = len(techniques)
else:
    tags = {
        str(tag).strip()
        for machine in machines
        for tag in (machine.get("tags") or [])
        if str(tag).strip()
    }
    technique_count = len(tags)

block = f"""<!-- PORTFOLIO_STATS_START -->
| Métrica | Total |
|---|---:|
| Máquinas | {len(machines)} |
| Plataformas | {len(platforms)} |
| Técnicas | {technique_count} |
<!-- PORTFOLIO_STATS_END -->"""

content = readme_path.read_text(encoding="utf-8")
pattern = re.compile(
    r"<!-- PORTFOLIO_STATS_START -->.*?<!-- PORTFOLIO_STATS_END -->",
    re.S
)

if pattern.search(content):
    content = pattern.sub(lambda _: block, content, count=1)
else:
    content = content.rstrip() + "\n\n" + block + "\n"

readme_path.write_text(content, encoding="utf-8")
PY
