#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

README="$REPO_ROOT/README.md"
MACHINES="$REPO_ROOT/docs/assets/data/machines.json"
TECHNIQUES="$REPO_ROOT/docs/assets/data/techniques.json"

[ -f "$README" ] || exit 0
[ -f "$MACHINES" ] || exit 0

python3 - "$README" "$MACHINES" "$TECHNIQUES" << 'PYEOF'
import json, re, sys
readme, machines, techniques = sys.argv[1], sys.argv[2], sys.argv[3]
with open(machines, encoding='utf-8') as f:
    m = json.load(f)
platforms = set()
for item in m:
    ps = item.get('platformSlug') or item.get('platform')
    if ps:
        platforms.add(str(ps).strip())
pcount = len([x for x in platforms if x])
if techniques and __import__('os').path.exists(techniques):
    with open(techniques, encoding='utf-8') as f:
        t = json.load(f)
    tcount = len(t)
else:
    tags = set()
    for item in m:
        for tg in (item.get('tags') or []):
            s = str(tg).strip()
            if s:
                tags.add(s)
    tcount = len(tags)
block = f"""<!-- PORTFOLIO_STATS_START -->
| Métrica | Total |
|---|---:|
| Máquinas | {len(m)} |
| Plataformas | {pcount} |
| Técnicas | {tcount} |
<!-- PORTFOLIO_STATS_END -->"""
with open(readme, encoding='utf-8') as f:
    content = f.read()
pattern = r'<!-- PORTFOLIO_STATS_START -->.*?<!-- PORTFOLIO_STATS_END -->'
if re.search(pattern, content, re.S):
    content = re.sub(pattern, block, content, count=1, flags=re.S)
else:
    content = content.rstrip() + '\n\n' + block + '\n'
with open(readme, 'w', encoding='utf-8') as f:
    f.write(content)
PYEOF
