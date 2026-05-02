"""
Script de configuration des données Warsh pour l'app Flutter.
Télécharge la police et pré-traite le JSON en un format compact par juz.
"""
import urllib.request
import json
import os
import math

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(BASE_DIR, 'assets', 'quran')
FONT_DIR = os.path.join(ASSETS_DIR, 'fonts')
DATA_DIR = os.path.join(ASSETS_DIR, 'data')

os.makedirs(FONT_DIR, exist_ok=True)
os.makedirs(DATA_DIR, exist_ok=True)

# ─── 1. Police Warsh ─────────────────────────────────────────────────────────
font_dest = os.path.join(FONT_DIR, 'warsh.ttf')
if not os.path.exists(font_dest):
    print('Téléchargement de la police Warsh KFGQPC...')
    font_url = 'https://cdn.jsdelivr.net/gh/thetruetruth/quran-data-kfgqpc@main/warsh/font/warsh.10.ttf'
    req = urllib.request.Request(font_url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=60) as r:
        data = r.read()
    with open(font_dest, 'wb') as f:
        f.write(data)
    print(f'  Police sauvegardée ({len(data):,} octets)')
else:
    print(f'  Police déjà présente: {font_dest}')

# ─── 2. Charger le JSON brut ─────────────────────────────────────────────────
raw_json = os.path.join(DATA_DIR, 'warsh.json')
print(f'\nChargement de {raw_json}...')
with open(raw_json, 'r', encoding='utf-8') as f:
    verses = json.load(f)
print(f'  {len(verses)} ayats chargés')

# ─── 3. Limites des hizbs (العد المدني الأخير) ────────────────────────────────
# Un juz = 2 hizbs. Le champ 'jozz' du JSON est le juz (1-30).
# Hizb h appartient au juz: ceil(h/2)
# Pour déterminer quelle moitié du juz c'est le hizb,
# on découpe chaque juz en 2 moitiés égales par nombre d'ayats.

# Grouper par juz
from collections import defaultdict
by_juz = defaultdict(list)
for v in verses:
    by_juz[v['jozz']].append(v)

# ─── 4. Générer quran_warsh_by_juz.json (format compact) ────────────────────
output = {}
for juz_num in range(1, 31):
    juz_verses = by_juz.get(juz_num, [])
    total = len(juz_verses)
    mid = total // 2

    # hizb1 = première moitié, hizb2 = deuxième moitié
    hizb1_idx = (juz_num - 1) * 2 + 1
    hizb2_idx = (juz_num - 1) * 2 + 2

    # Supprime le marqueur de fin d'ayah déjà inclus dans les données KFGQPC :
    # espace(s) + ۝ (U+06DD) + chiffres arabo-indics/perso-arabes
    import re as _re
    _trail = _re.compile(r'[\s\u06DD\u0660-\u06F9]+$')

    def serialize(v):
        return {
            'k': f"{v['sura_no']}:{v['aya_no']}",  # clé: "surah:ayah"
            's': v['sura_no'],
            'a': v['aya_no'],
            't': _trail.sub('', v['aya_text']),
            'sn': v['sura_name_ar'].strip(),
        }

    output[str(hizb1_idx)] = [serialize(v) for v in juz_verses[:mid]]
    output[str(hizb2_idx)] = [serialize(v) for v in juz_verses[mid:]]

out_path = os.path.join(DATA_DIR, 'quran_warsh_hizb.json')
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, separators=(',', ':'))

size_kb = os.path.getsize(out_path) / 1024
print(f'\nFichier généré: {out_path}')
print(f'  Taille: {size_kb:.1f} KB')

# Vérification
total_verses = sum(len(v) for v in output.values())
print(f'  Total ayats indexés: {total_verses}')
print(f'  Hizbs générés: {sorted(int(k) for k in output.keys())}')
print('\n✅ Configuration terminée!')
print(f'Police : assets/quran/fonts/warsh.ttf')
print(f'Données: assets/quran/data/quran_warsh_hizb.json')
