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

# A checker sees only what its glob names, so both halves of this list matter.
#
# Shared policy files live at the Study root, outside the project glob: list
# them explicitly or nobody checks them.
#
# EVERY .md under the project, not only the top level: refs/NOTES.md carries
# dozens of references to our own numbered items and to source item numbers,
# and it once sat outside this glob for weeks.  Keep the recursive form when
# .md files appear in a new directory.
MD    = ['../CLAUDE.md', '../PHASE1_PROBE_GUIDE.md', '../README.md'] \
        + sorted(glob.glob('**/*.md', recursive=True))
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

# Abbreviated English forms, as used in refs/NOTES.md when it records which of
# OUR items a source item ended up in.  Same target prefixes.
KIND_EN = {'Thm':'thm', 'Theorem':'thm', 'Prop':'prop', 'Proposition':'prop',
           'Lem':'lem', 'Lemma':'lem', 'Cor':'cor', 'Corollary':'cor',
           'Def':'def', 'Definition':'def', 'Ex':'ex', 'Example':'ex',
           'Rmk':'rem', 'Remark':'rem'}

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

    # 3a. cross-references against the .aux files, Korean form: `ch07` 비고 7.34
    for m in re.finditer(r'`ch(\d\d)`\s*(비고|정리|명제|보조정리|정의|예|따름정리)'
                         r'\s*([0-9]+\.[0-9]+)', txt):
        labs = num2lab.get(m.group(3), [])
        if not any(l.startswith(KIND[m.group(2)] + ':') for l in labs):
            ln = txt[:m.start()].count('\n') + 1
            bad('xref', f'{show}:{ln}',
                f'{m.group(0)} -> {", ".join(labs) or "no such number"}')

    # 3b. OUR items in the abbreviated English form, "Ch06 Ex 6.6" or
    # "P3 Rmk 10.15".
    # The chapter prefix is required and is not decoration: the target paper's
    # own items are written the same way otherwise ("Thm 1.2"), and the numbers
    # collide.  Bare "Thm 1.2" is therefore reserved for the target paper and is
    # checked by nothing here; anything referring to OUR book must carry its
    # chapter.
    #   ChNN ...  a Part I chapter: number, kind AND chapter are verified.
    #   PN / PNa  a Part II chapter: number and kind are verified.  Part II
    #             chapters are numbered after Part I, so the chapter digit is
    #             not recoverable from the label -- do not try.
    # The prefix is often written in backticks in running prose (`P4b` Rmk
    # 12.14).  strip_code() would delete it and the reference would then look
    # like the target paper's own "Rmk 12.14" and be checked by nothing -- a
    # whole class of references escaped this check that way.  Unwrap the prefix
    # BEFORE stripping code spans.
    body = strip_code(re.sub(r'`(Ch\d\d|P\d[ab]?)`', r'\1', txt))
    for m in re.finditer(r'(?:`?Ch(\d\d)`?|`?P\d[ab]?`?)\s+(' + '|'.join(KIND_EN) +
                         r')\.?~?\s*([0-9]+)\.([0-9]+)(?![0-9])(?!\.[0-9])',
                         body):
        ch, kind, maj, minr = m.group(1), m.group(2), m.group(3), m.group(4)
        num  = f'{maj}.{minr}'
        labs = num2lab.get(num, [])
        ln   = body[:m.start()].count('\n') + 1
        if ch is not None and int(maj) != int(ch):
            bad('xref', f'{show}:~{ln}', f'{m.group(0)} -> chapter is {ch}')
        elif not labs:
            bad('xref', f'{show}:~{ln}', f'{m.group(0)} -> no such number')
        elif not any(l.startswith(KIND_EN[kind] + ':') for l in labs):
            bad('xref', f'{show}:~{ln}',
                f'{m.group(0)} -> {", ".join(labs)}')

LABEL = {'macro': 'project macro outside backticks',
         'pipe' : 'pipe inside math inside a table row',
         'table': 'table column count',
         'math' : 'inline math not closed on its line',
         'xref' : 'cross-reference does not match the .aux files          ',
         'escape': 'leaked \\uXXXX escape',
         'approval': 'chapter table vs approval log'}


# ---------------------------------------------------------------- approvals
# The "chapter status" table and the "approval log" of progress.md record the
# same fact in two places, and nothing else compares them: the agreement of two
# tables is a matter of meaning, not of syntax.  In one project they drifted
# twice -- a chapter was approved, the log said so, and the table's approval
# column stayed unticked -- and both times a human caught it rather than a
# checker.  So we check it here.
#
# Rule: chapter NN is ticked in the status table  <=>  the approval log has a
# row naming **ChNN** and marked as approved.
#
# Both tables are part of the template, so this applies to every project.  The
# empty placeholder rows of a fresh project match neither pattern and are
# silently ignored.
#
# TWO SPELLINGS, both in use and both must be understood, or the check reports
# a whole project's chapters as drifted and gets ignored as noise:
#   - the approval cell is a tick (U+2611 / U+2610) in some projects and the
#     word 승인 in others;
#   - the log names the chapter **Ch01** or **`Ch01`**.
import re as _re
def _approved(cell):
    return ('대기' not in cell) and ('승인' in cell or '☑' in cell)
_prog = 'progress.md'
if os.path.exists(_prog):
    _txt = open(_prog, encoding='utf-8').read()
    _ticked, _logged = set(), set()
    for _l in _txt.split('\n'):
        # Read the row by CELLS, never by one regex over the whole line: a
        # chapter title beginning with a lowercase letter ("klt, plt, and lc")
        # once fell out of such a regex, and the row was then silently absent
        # from both sides of the comparison.
        _c = [x.strip() for x in _l.strip().strip('|').split('|')] \
             if _l.lstrip().startswith('|') else []
        if len(_c) >= 4 and _re.fullmatch(r'\d{2}', _c[0]) \
                and ('신규' in _l or 'import:' in _l):
            if _approved(_c[-1]):
                _ticked.add(_c[0])
        _m2 = _re.search(r'\*\*`?Ch(\d{2})`?\*\*', _l)
        if _m2 and '| 승인 |' in _l:
            _logged.add(_m2.group(1))
    for _ch in sorted(_ticked - _logged):
        issues.append(('approval', f'{_prog}',
                       f'Ch{_ch} is ticked in the chapter table but has no approval-log row'))
    for _ch in sorted(_logged - _ticked):
        issues.append(('approval', f'{_prog}',
                       f'Ch{_ch} is in the approval log but not ticked in the chapter table'))

    # Phase 5 duplicates the same fact in the same two places: the "paper
    # reading status" table and the approval log.  The rule above sees only
    # ChNN rows, so until this was added the Part II half of the book was
    # unchecked -- the exact shape of the Part I drift, one Part later.
    #
    # Rule: a Part II chapter marked approved in the reading-status table  <=>
    # the approval log has a row naming it and marked as approved.
    # "승인 대기" (awaiting approval) contains the word 승인 and must not count,
    # hence the explicit 대기 exclusion on both sides.
    #
    # The two tables name the same chapter differently, and both spellings are
    # in use across projects: the reading table always holds the file name
    # (paper/sec04a-...), while the approval log names it either **sec04a** or
    # **P4a**.  Normalise to the file-name form before comparing, or the check
    # reports every Part II chapter of a P-naming project as missing.
    _sticked, _slogged = set(), set()
    for _l in _txt.split('\n'):
        _c = [x.strip() for x in _l.strip().strip('|').split('|')] \
             if _l.lstrip().startswith('|') else []
        _m3 = _re.match(r'`?paper/sec(\d{2}[ab]?)', _c[1]) if len(_c) >= 4 else None
        if _m3 and _approved(_c[3]):
            _sticked.add(_m3.group(1))
        _m4 = _re.search(r'\*\*`?sec(\d{2}[ab]?)`?\*\*', _l)
        if _m4 and '| 승인 |' in _l:
            _slogged.add(_m4.group(1))
        _m5 = _re.search(r'\*\*`?P(\d{1,2})([ab]?)`?\*\*', _l)
        if _m5 and '| 승인 |' in _l:
            _slogged.add(f'{int(_m5.group(1)):02d}{_m5.group(2)}')
    for _s in sorted(_sticked - _slogged):
        issues.append(('approval', f'{_prog}',
                       f'sec{_s} is approved in the reading table but has no '
                       f'approval-log row'))
    for _s in sorted(_slogged - _sticked):
        issues.append(('approval', f'{_prog}',
                       f'sec{_s} is in the approval log but not approved in '
                       f'the reading table'))

print('== md files checked ==')
for f in MD:
    if os.path.exists(f): print('  ' + f.replace('../', ''))
print(f'== .aux files read: {len(AUX)}; numbered items: {len(num2lab)} ==')
if not AUX:
    print('  WARNING: no .aux found -- run tex/check.sh first, xrefs unchecked')

for kind in ('macro', 'pipe', 'table', 'math', 'xref', 'escape', 'approval'):
    hits = [x for x in issues if x[0] == kind]
    print(f'  {LABEL[kind]:<46} {len(hits)}')
    for _, where, what in hits:
        print(f'      {where}  {what}')

print('== result ==')
print(f'  {len(issues)} issue(s)')
sys.exit(1 if issues else 0)
PY
