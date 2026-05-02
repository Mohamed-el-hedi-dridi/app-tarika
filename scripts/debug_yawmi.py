#!/usr/bin/env python3
"""Fix الضالين ending in wird_yawmi_data.dart"""
import unicodedata

filepath = 'lib/data/wird_yawmi_data.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Find الضالين
idx = content.find('\u0627\u0644\u0636\u0627\u0644')  # الضال
if idx >= 0:
    snippet = content[idx:idx+20]
    print('Found snippet:', repr(snippet))
    for c in snippet:
        print(f'  U+{ord(c):04X} [{c}] {unicodedata.name(c, "?")}')
else:
    print('NOT FOUND - searching more broadly...')
    idx2 = content.find('\u0636\u0627\u0644')  # ضال
    if idx2 >= 0:
        print('Found ضال at:', idx2)
        print(repr(content[idx2-5:idx2+15]))
        for c in content[idx2-5:idx2+15]:
            print(f'  U+{ord(c):04X} [{c}] {unicodedata.name(c, "?")}')
