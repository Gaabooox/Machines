#!/usr/bin/env python3
import json
import os
import re
import subprocess
from datetime import datetime
from pathlib import Path
from collections import OrderedDict

SCRIPT_DIR = Path(__file__).parent.resolve()
REPO_ROOT = SCRIPT_DIR.parent

def write_utf8(path, content):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding='utf-8')

def to_slug(text):
    if not text:
        return ""
    # simple normalization
    text = text.lower()
    text = re.sub(r'[^a-z0-9]+', '-', text)
    return text.strip('-')

def get_machine_date(repo_root, rel_writeup, abs_writeup, existing_date):
    if existing_date and existing_date.strip():
        return existing_date.strip()
    try:
        result = subprocess.run(
            ['git', '-C', str(repo_root), 'log', '--follow', '--format=%cs', '--', rel_writeup],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=str(repo_root)
        )
        if result.returncode == 0:
            out = result.stdout.decode('utf-8', errors='ignore').strip()
            if out:
                dates = [d.strip() for d in out.splitlines() if d.strip()]
                if dates:
                    return dates[-1]
    except Exception:
        pass
    try:
        if abs_writeup.exists():
            mtime = datetime.fromtimestamp(abs_writeup.stat().st_mtime)
            return mtime.strftime('%Y-%m-%d')
    except Exception:
        pass
    return datetime.now().strftime('%Y-%m-%d')

def main():
    json_path = REPO_ROOT / 'docs' / 'assets' / 'data' / 'machines.json'
    if not json_path.exists():
        raise SystemExit(f'No existe: {json_path}')
    
    with json_path.open('r', encoding='utf-8') as f:
        machines = json.load(f)
    
    normalized = []
    for m in machines:
        platform_slug = str(m.get('platformSlug') or '')
        difficulty_slug = str(m.get('difficultySlug') or '')
        slug = str(m.get('slug') or '')
        rel_writeup = f"docs/{platform_slug}/{difficulty_slug}/{slug}.md"
        abs_writeup = REPO_ROOT / rel_writeup
        resolved_date = get_machine_date(REPO_ROOT, rel_writeup, abs_writeup, str(m.get('date') or ''))
        tags = m.get('tags') or []
        if isinstance(tags, str):
            tags = [t.strip() for t in tags.split(',') if t.strip()]
        normalized.append({
            'name': str(m.get('name') or ''),
            'slug': slug,
            'platform': str(m.get('platform') or ''),
            'platformSlug': platform_slug,
            'difficulty': str(m.get('difficulty') or ''),
            'difficultySlug': difficulty_slug,
            'operatingSystem': str(m.get('operatingSystem') or ''),
            'status': str(m.get('status') or 'Completada'),
            'path': str(m.get('path') or ''),
            'summary': str(m.get('summary') or ''),
            'access': str(m.get('access') or ''),
            'escalation': str(m.get('escalation') or ''),
            'date': resolved_date,
            'tags': tags
        })
    
    write_utf8(json_path, json.dumps(normalized, ensure_ascii=False, indent=2))
    
    technique_map = {}
    for machine in normalized:
        for tag in machine.get('tags', []):
            tag_clean = str(tag).strip()
            if not tag_clean:
                continue
            key = tag_clean.lower()
            if key not in technique_map:
                technique_map[key] = {
                    'name': tag_clean,
                    'slug': to_slug(tag_clean),
                    'count': 0,
                    'machines': []
                }
            technique_map[key]['count'] += 1
            technique_map[key]['machines'].append({
                'name': machine['name'],
                'path': machine['path'],
                'platform': machine['platform'],
                'difficulty': machine['difficulty'],
                'operatingSystem': machine['operatingSystem'],
                'date': machine['date']
            })
    
    techniques = []
    for t in technique_map.values():
        t['machines'] = sorted(t['machines'], key=lambda x: x['name'])
        techniques.append(t)
    techniques.sort(key=lambda x: (-x['count'], x['name']))
    
    techniques_path = REPO_ROOT / 'docs' / 'assets' / 'data' / 'techniques.json'
    write_utf8(techniques_path, json.dumps(techniques, ensure_ascii=False, indent=2))
    
    timeline = []
    for machine in normalized:
        def parse_date(d):
            try:
                return datetime.strptime(d, '%Y-%m-%d')
            except Exception:
                return datetime.min
        timeline.append({
            'name': machine['name'],
            'slug': machine['slug'],
            'path': machine['path'],
            'platform': machine['platform'],
            'difficulty': machine['difficulty'],
            'operatingSystem': machine['operatingSystem'],
            'summary': machine['summary'],
            'date': machine['date'],
            'year': machine['date'][:4] if re.match(r'^\d{4}', machine['date']) else 'Sin fecha',
            'tags': machine['tags']
        })
    timeline.sort(key=lambda x: (parse_date(x['date']), x['name']), reverse=True)
    
    timeline_path = REPO_ROOT / 'docs' / 'assets' / 'data' / 'timeline.json'
    write_utf8(timeline_path, json.dumps(timeline, ensure_ascii=False, indent=2))
    
    search_entries = []
    for machine in normalized:
        keywords = ' '.join(filter(None, [
            machine['platform'],
            machine['difficulty'],
            machine['operatingSystem'],
            machine['access'],
            machine['escalation'],
            ' '.join(machine['tags'])
        ]))
        search_entries.append({
            'type': 'machine',
            'title': machine['name'],
            'url': machine['path'],
            'subtitle': f"{machine['platform']} · {machine['difficulty']} · {machine['operatingSystem']}",
            'content': machine['summary'],
            'keywords': keywords
        })
    
    for technique in techniques:
        machine_names = [m['name'] for m in technique['machines']]
        search_entries.append({
            'type': 'technique',
            'title': technique['name'],
            'url': f"techniques/#{technique['slug']}",
            'subtitle': f"{technique['count']} máquina(s)",
            'content': f"Utilizada en: {', '.join(machine_names)}",
            'keywords': ' '.join(machine_names)
        })
    
    allowed_langs = {'', 'bash', 'shell', 'sh', 'zsh', 'powershell', 'pwsh', 'python', 'ruby', 'vim'}
    for machine in normalized:
        writeup_path = REPO_ROOT / 'docs' / machine['platformSlug'] / machine['difficultySlug'] / f"{machine['slug']}.md"
        if not writeup_path.exists():
            continue
        try:
            lines = writeup_path.read_text(encoding='utf-8').splitlines()
        except Exception:
            continue
        inside_code = False
        code_lang = ''
        code_lines = []
        current_anchor = ''
        current_heading = machine['name']
        for line in lines:
            if not inside_code:
                m = re.match(r'^(#{2,3})\s+(.+?)\s*$', line)
                if m:
                    current_heading = m.group(2).strip()
                    current_anchor = to_slug(current_heading)
                    continue
                m = re.match(r'^```([A-Za-z0-9_-]*)\s*$', line)
                if m:
                    inside_code = True
                    code_lang = (m.group(1) or '').lower()
                    code_lines = []
                    continue
            if inside_code:
                if re.match(r'^```\s*$', line):
                    inside_code = False
                    if code_lang in allowed_langs and code_lines:
                        code_content = '\n'.join(code_lines).strip()
                        if code_content:
                            # first non-empty line
                            first = None
                            for cl in code_lines:
                                if cl.strip():
                                    first = cl.strip()
                                    break
                            title = first if first else 'Comando'
                            if len(title) > 72:
                                title = title[:69] + '...'
                            url = machine['path']
                            if current_anchor:
                                url += f'#{current_anchor}'
                            search_entries.append({
                                'type': 'command',
                                'title': title,
                                'url': url,
                                'subtitle': f"{machine['name']} · {current_heading}",
                                'content': code_content,
                                'keywords': f"{machine['name']} {machine['platform']} {code_lang}"
                            })
                    code_lines = []
                    code_lang = ''
                    continue
                else:
                    code_lines.append(line)
    
    search_path = REPO_ROOT / 'docs' / 'assets' / 'data' / 'search-index.json'
    write_utf8(search_path, json.dumps(search_entries, ensure_ascii=False, indent=2))
    
    print('Datos regenerados:')
    print(f'- Máquinas: {len(normalized)}')
    print(f'- Técnicas: {len(techniques)}')
    print(f'- Entradas de búsqueda: {len(search_entries)}')
    print(f'- Línea temporal: {len(timeline)}')
    
    updater = SCRIPT_DIR / 'update-readme.sh'
    if updater.exists():
        os.system(f'bash "{updater}"')

if __name__ == '__main__':
    main()
