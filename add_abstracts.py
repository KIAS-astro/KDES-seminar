#!/usr/bin/env python3
"""
Parse meeting abstracts from meetings_raw.txt and inject them into year HTML files.
Uses <details>/<summary> for collapsible abstract display.
"""

import re
import os

BASE = os.path.dirname(os.path.abspath(__file__))
SITE = os.path.join(BASE, "site")

# --- 1. Parse abstracts ---

with open(os.path.join(BASE, "meetings_raw.txt"), "r") as f:
    text = f.read()

blocks = re.split(r'\n={10,}.*?\n', text)

abstract_db = {}  # normalized_key -> abstract text

def normalize(s):
    s = s.lower()
    s = re.sub(r'[^a-z0-9 ]', ' ', s)
    s = re.sub(r'\s+', ' ', s).strip()
    return s

for block in blocks:
    talk_starts = [(m.start(), m.group()) for m in re.finditer(r'(?m)^\d+\.\s+', block)]

    for i, (pos, prefix) in enumerate(talk_starts):
        end = talk_starts[i+1][0] if i+1 < len(talk_starts) else len(block)
        chunk = block[pos:end]

        abs_match = re.search(r'\n[-\s]*Abstract:\s*', chunk, re.IGNORECASE)
        if not abs_match:
            continue

        title_part = chunk[:abs_match.start()]
        abstract_text = chunk[abs_match.end():]
        abstract_text = re.sub(r'\s+', ' ', abstract_text).strip()

        title_part = re.sub(r'\s+', ' ', title_part).strip()
        title_part = re.sub(r'^\d+\.\s*', '', title_part)
        # Remove trailing speaker parenthetical
        title_clean = re.sub(r'\s*\([^()]+\)\s*$', '', title_part).strip()

        key = normalize(title_clean)
        if key and abstract_text:
            abstract_db[key] = abstract_text
            words = key.split()
            for n in (6, 5, 4):
                if len(words) >= n:
                    short_key = ' '.join(words[:n])
                    if short_key not in abstract_db:
                        abstract_db[short_key] = abstract_text

print(f"Parsed {len(abstract_db)} abstract entries.")


def find_abstract(html_title):
    """Find abstract for a given HTML title string."""
    key = normalize(html_title)
    if key in abstract_db:
        return abstract_db[key]
    words = key.split()
    for n in (6, 5, 4, 3):
        if len(words) >= n:
            short = ' '.join(words[:n])
            if short in abstract_db:
                return abstract_db[short]
    return None


def escape_html(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


# --- 2. Process each year HTML file ---

YEAR_FILES = [str(y) + ".html" for y in range(2013, 2027)]

total_added = 0

for fname in YEAR_FILES:
    fpath = os.path.join(SITE, fname)
    if not os.path.exists(fpath):
        continue

    with open(fpath, "r", encoding="utf-8") as f:
        html = f.read()

    # Match each <li> item: <li><b>TITLE</b> (Speaker, Institution)
    # We'll look for the pattern and inject a <details> block after it
    li_pattern = re.compile(
        r'(<li><b>(.*?)</b>([^<\n]*))',
        re.DOTALL
    )

    modified = False
    new_html = []
    last_end = 0

    for m in li_pattern.finditer(html):
        full_li = m.group(1)
        title = m.group(2).strip()
        rest = m.group(3).strip()

        new_html.append(html[last_end:m.start()])
        new_html.append(full_li)

        abstract = find_abstract(title)
        if abstract:
            # Escape and wrap
            abs_html = escape_html(abstract)
            new_html.append(
                f'\n<details class="abstract"><summary>Abstract</summary>'
                f'<p class="abstract-text">{abs_html}</p></details>'
            )
            modified = True
            total_added += 1

        last_end = m.end()

    new_html.append(html[last_end:])
    new_content = ''.join(new_html)

    if modified:
        with open(fpath, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"  Updated {fname}")
    else:
        print(f"  No changes: {fname}")

print(f"\nTotal abstracts injected: {total_added}")
