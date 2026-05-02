#!/usr/bin/env python3
"""Script to fix verse numbers in wird_aam_data.dart"""

import re

filepath = 'lib/data/wird_aam_data.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

changes = 0

# ─── 1. Fix typo لللَّهِ → لِلَّهِ ────────────────────────────────────────────
old_typo = 'وَالْحَمْدُ لللَّهِ'
new_correct = 'وَالْحَمْدُ لِلَّهِ'
n = content.count(old_typo)
print(f'Typo لللَّهِ occurrences: {n}')
content = content.replace(old_typo, new_correct)
changes += n

# ─── 2. Add startVerseNumber ────────────────────────────────────────────────

def add_verse_num_normal(c, title, verse):
    """Add startVerseNumber after 'isQuranVerse: true,\\n    text:' for title."""
    old = f"title: '{title}',\n    isQuranVerse: true,\n    text:"
    new = f"title: '{title}',\n    isQuranVerse: true,\n    startVerseNumber: {verse},\n    text:"
    n = c.count(old)
    if n == 0:
        print(f'  NOT FOUND: {title}')
        return c
    if n > 1:
        print(f'  MULTIPLE ({n}): {title} - replacing ALL')
    c = c.replace(old, new)
    print(f'  Added startVerseNumber:{verse} to "{title}" ({n} occurrences)')
    return c

def add_verse_num_inline(c, title, verse):
    """Add startVerseNumber for compact-formatted items (title, isQuranVerse, text on same line)."""
    old = f"title: '{title}',    isQuranVerse: true,    text:"
    new = f"title: '{title}',    isQuranVerse: true,    startVerseNumber: {verse},    text:"
    n = c.count(old)
    if n == 0:
        print(f'  NOT FOUND inline: {title}')
        return c
    c = c.replace(old, new)
    print(f'  Added startVerseNumber:{verse} to "{title}" (inline, {n} occurrences)')
    return c

# Normal format items (title on own line)
items_normal = [
    ('سورة الإخلاص', 1),
    ('سورة الفلق', 1),
    ('سورة الناس', 1),
    ('ختام الورد', 180),
]
for title, verse in items_normal:
    content = add_verse_num_normal(content, title, verse)

# Inline format items (title, isQuranVerse, text all crammed together)
items_inline = [
    ('سورة الفاتحة', 2),
    ('سورة الملك', 1),
]
for title, verse in items_inline:
    content = add_verse_num_inline(content, title, verse)

# ─── 3. Add ۝ at end of surah texts ─────────────────────────────────────────

def add_end_ayah_marker(c, last_verse_text):
    """Add ۝ at end of verse text (before closing quote)."""
    old = f"'{last_verse_text}',"
    new = f"'{last_verse_text} \u06dd',"
    n = c.count(old)
    print(f'  End marker "{last_verse_text[:35]}": {n} occurrences')
    if n > 0:
        c = c.replace(old, new)
    return c

# These must be unique last lines of each surah
endings = [
    'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',        # Al-Ikhlas v4
    'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',          # Al-Falaq v5
    'مِنَ الْجِنَّةِ وَالنَّاسِ',                # Al-Nas v6
    'غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',  # Fatiha v7
    'فَمَن يَأْتِيكُم بِمَاءٍ مَّعِينٍ',          # Al-Mulk v30
]

for ending in endings:
    content = add_end_ayah_marker(content, ending)

# ─── 4. Write back ──────────────────────────────────────────────────────────

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print(f'\nDone. Total changes: wrote file.')

# Verify
with open(filepath, 'r', encoding='utf-8') as f:
    verify = f.read()
count_sv = verify.count('startVerseNumber')
print(f'startVerseNumber occurrences after: {count_sv}')
count_typo = verify.count('لللَّهِ')
print(f'Typo occurrences after: {count_typo}')
