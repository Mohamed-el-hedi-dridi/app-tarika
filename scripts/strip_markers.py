import json, re, sys

path = 'assets/quran/data/quran_warsh_hizb.json'
trail = re.compile(r'[\s\u06DD\u0660-\u06F9]+$')

with open(path, encoding='utf-8') as f:
    data = json.load(f)

changed = 0
for hizb_verses in data.values():
    for v in hizb_verses:
        cleaned = trail.sub('', v['t'])
        if cleaned != v['t']:
            changed += 1
            v['t'] = cleaned

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, separators=(',', ':'))

print(f'Done. {changed} versets modifies.')
for v in data['1'][:3]:
    tail_hex = [hex(ord(c)) for c in v['t'][-6:]]
    print(v['t'][-10:], '->', tail_hex)
sys.stdout.flush()
