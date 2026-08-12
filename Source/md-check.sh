#!/bin/sh
# md-check.sh -- verification for the management files (spec/background/progress).
#
# Why this exists: three classes of defect are invisible on inspection but break
# rendering or mislead the reader, and all three were found by hand on
# 2026-08-07 after they had survived several sessions.
#
#   1. Project macros in markdown.  CLAUDE.md forbids \ddc, \Oc, \hyp, ... in
#      these files: they are read on GitHub, which knows only standard
#      LaTeX/MathJax.  A macro mention must be wrapped in backticks.
#   2. Table-breaking pipes.  In a markdown table cell a vertical bar is read as
#      a column separator BEFORE inline code or math is processed, so even
#      `\log|s|_h` inside backticks splits the row.  Use \lvert and \rvert.
#   3. Stale cross-references.  "ch07 remark 7.34" is checked against the
#      numbers LaTeX actually assigned, read from every .aux under tex/.
#      These drift silently whenever a remark is inserted into a chapter.
#
# Also flags inline math that is not closed on its own line -- which silently
# exposes every command in it -- and \uXXXX escapes leaked by tooling.
#
# Run tex/check.sh first: the cross-reference check reads the .aux files, so it
# is only as fresh as the last build.
#
# Usage:  sh md-check.sh
set -e
cd "$(dirname "$0")"

python3 - "$@" <<'PY'
import re, glob, sys, os

# Shared policy files live at the Study root, outside this project's glob.  A
# checker sees only what its glob names: list them explicitly or nobody checks
# them.
MD    = ['../CLAUDE.md', '../PHASE1_PROBE_GUIDE.md', '../README.md'] \
        + sorted(glob.glob('*.md'))
AUX   = sorted(f for f in glob.glob('tex/**/*.aux', recursive=True)
                 if os.path.basename(f) != 'main.aux')

# Macros defined under tex/: legal there, not in these files.  Read from the
# style files themselves, so that a new macro is policed the moment it exists.
PROJECT = set()
for sty in glob.glob('tex/*.sty') + glob.glob('tex/*.tex'):
    try: src = open(sty, encoding='utf-8', errors='replace').read()
    except OSError: continue
    PROJECT |= set(re.findall(
        r'\\(?:new|renew|provide)command\{?\\([A-Za-z]+)', src))
    PROJECT |= set(re.findall(r'\\DeclareMathOperator\*?\{?\\([A-Za-z]+)', src))
PROJECT -= {'P'}          # \P is redefined but also plain LaTeX; too noisy

KIND = {'비고':'rem', '정리':'thm', '명제':'prop', '보조정리':'lem',
        '정의':'def', '예':'ex', '따름정리':'cor'}

def strip_code(t):
    t = re.sub(r'```.*?```', '', t, flags=re.S)
    return re.sub(r'`[^`\n]*`', '', t)

# ---- numbers LaTeX actually assigned -------------------------------------
num2lab = {}
for a in AUX:
    try: src = open(a, encoding='utf-8', errors='replace').read()
    except OSError: continue
    for m in re.finditer(r'newlabel\{([^}]+)\}\{\{([0-9]+\.[0-9]+)\}', src):
        num2lab.setdefault(m.group(2), []).append(m.group(1))

issues = []
def bad(kind, where, what):
    issues.append((kind, where, what))

for f in MD:
    if not os.path.exists(f): continue
    txt   = open(f, encoding='utf-8').read()
    lines = txt.split('\n')
    show  = f.replace('../', '')

    # 1. project macros outside code
    for m in re.finditer(r'\\([A-Za-z]+)', strip_code(txt)):
        if m.group(1) in PROJECT:
            ln = txt[:m.start()].count('\n') + 1
            bad('macro', f'{show}:{ln}', '\\' + m.group(1))

    # 4. leaked escapes
    for m in re.finditer(r'\\u[0-9a-fA-F]{4}', txt):
        bad('escape', f'{show}:{txt[:m.start()].count(chr(10))+1}', m.group(0))

    for i, l in enumerate(lines, 1):
        # 2a. inline math not closed on its own line
        if strip_code(l).count('$') % 2:
            bad('math', f'{show}:{i}', l.strip()[:60])
        # 2b. pipe inside math inside a table row
        if l.lstrip().startswith('|'):
            for mm in re.finditer(r'\$[^$\n]*\$', l):
                if '|' in mm.group(0):
                    bad('pipe', f'{show}:{i}', mm.group(0)[:50])

    # 2c. table column counts
    i = 0
    while i < len(lines):
        if (re.match(r'^\s*\|.*\|\s*$', lines[i]) and i + 1 < len(lines)
                and re.match(r'^\s*\|[\s:|-]+\|\s*$', lines[i + 1])):
            n, j = lines[i].count('|'), i
            while j < len(lines) and re.match(r'^\s*\|', lines[j]):
                if lines[j].count('|') != n:
                    bad('table', f'{show}:{j+1}',
                        f'{lines[j].count("|")} bars, header has {n}')
                j += 1
            i = j
        else:
            i += 1

    # 3. cross-references against the .aux files
    for m in re.finditer(r'`ch(\d\d)`\s*(비고|정리|명제|보조정리|정의|예|따름정리)'
                         r'\s*([0-9]+\.[0-9]+)', txt):
        labs = num2lab.get(m.group(3), [])
        if not any(l.startswith(KIND[m.group(2)] + ':') for l in labs):
            ln = txt[:m.start()].count('\n') + 1
            bad('xref', f'{show}:{ln}',
                f'{m.group(0)} -> {", ".join(labs) or "no such number"}')

LABEL = {'macro': 'project macro outside backticks',
         'pipe' : 'pipe inside math inside a table row',
         'table': 'table column count',
         'math' : 'inline math not closed on its line',
         'xref' : 'cross-reference does not match the .aux files          ',
         'escape': 'leaked \\uXXXX escape'}

print('== md files checked ==')
for f in MD:
    if os.path.exists(f): print('  ' + f.replace('../', ''))
print(f'== .aux files read: {len(AUX)}; numbered items: {len(num2lab)} ==')
if not AUX:
    print('  WARNING: no .aux found -- run tex/check.sh first, xrefs unchecked')

for kind in ('macro', 'pipe', 'table', 'math', 'xref', 'escape'):
    hits = [x for x in issues if x[0] == kind]
    print(f'  {LABEL[kind]:<46} {len(hits)}')
    for _, where, what in hits:
        print(f'      {where}  {what}')

print('== result ==')
print(f'  {len(issues)} issue(s)')
sys.exit(1 if issues else 0)
PY
