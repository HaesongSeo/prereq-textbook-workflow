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
#   4. Grade columns turned into prose.  CLAUDE.md requires the K/L/A-D codes
#      to be spelled out in the CHAT and requires them to stay coded in THESE
#      files; the second half needs a checker because the first half invites
#      the mistake.  See the GRADE_COLS block below.
#   5. A table copied into a second file and then edited in only one of them,
#      and the state block at the top of progress.md disagreeing with the
#      approval log.  Both are the same defect as (3) one level up: a fact
#      written twice drifts, and only a checker notices.
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
MD    = ['../CLAUDE.en.md', '../PHASE1_PROBE_GUIDE.en.md', '../README.en.md'] \
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
         'approval': 'chapter table vs approval log',
         'grade': 'grade column spelled out instead of coded',
         'state': 'state block vs approval log',
         'ssot' : 'SSOT-COPY table vs its canonical'}


# --------------------------------------------------------------- SSOT tables
# The same table legitimately appears in more than one file -- README.md has to
# introduce the method, background.md has to sit open while grading.  What is
# not legitimate is one copy being edited and nobody noticing.
#
# A canonical table is marked   <!-- SSOT-CANON: name -->
# a copy is marked              <!-- SSOT-COPY: name -->
# and the marker sits on its own line just above the table.
#
# Rule: a copy may COVER the canonical but may not CHANGE it.  Same number of
# rows and columns, and every canonical cell must appear inside the copy's cell
# in the same position.  So README's "| **A** 배경 언급만 |" passes against
# "| **A** |", and changing an L1 to an L2 does not.
def _table_at(lines, start):
    """Read the markdown table that begins within 4 lines after `start`."""
    for k in range(start, min(start + 5, len(lines))):
        if (re.match(r'^\s*\|.*\|\s*$', lines[k]) and k + 1 < len(lines)
                and re.match(r'^\s*\|[\s:|-]+\|\s*$', lines[k + 1])):
            rows, j = [], k
            while j < len(lines) and re.match(r'^\s*\|', lines[j]):
                if not re.match(r'^\s*\|[\s:|-]+\|\s*$', lines[j]):
                    rows.append([c.strip().strip('*` ').strip()
                                 for c in lines[j].strip().strip('|').split('|')])
                j += 1
            return rows, k + 1
    return None, start + 1

canon, copies = {}, []
for f in MD:
    if not os.path.exists(f): continue
    lines = open(f, encoding='utf-8').read().split('\n')
    show  = f.replace('../', '')
    for i, l in enumerate(lines):
        m = re.match(r'^\s*<!--\s*SSOT-(CANON|COPY):\s*([\w-]+)\s*-->\s*$', l)
        if not m: continue
        rows, ln = _table_at(lines, i + 1)
        if rows is None:
            bad('ssot', f'{show}:{i+1}', f'{m.group(2)}: marker with no table')
        elif m.group(1) == 'CANON':
            canon[m.group(2)] = (show, ln, rows)
        else:
            copies.append((m.group(2), show, ln, rows))

for name, show, ln, rows in copies:
    if name not in canon:
        bad('ssot', f'{show}:{ln}', f'{name}: no canonical table declared')
        continue
    cshow, _, crows = canon[name]
    if len(rows) != len(crows):
        bad('ssot', f'{show}:{ln}',
            f'{name}: {len(rows)} rows, canonical ({cshow}) has {len(crows)}')
        continue
    for r, (cr, rr) in enumerate(zip(crows, rows)):
        if len(cr) != len(rr):
            bad('ssot', f'{show}:{ln+r}',
                f'{name}: row {r+1} has {len(rr)} cells, canonical has {len(cr)}')
            continue
        for c, (cc, rc) in enumerate(zip(cr, rr)):
            if cc and cc not in rc:
                bad('ssot', f'{show}:{ln+r}',
                    f'{name}: row {r+1} col {c+1} lost "{cc}" (found "{rc[:24]}")')


# ---------------------------------------------------------- progress.md state
# The state block is the canonical value of phase / last_approved / which
# chapters are approved (CLAUDE.md §2).  It exists so that resuming a session
# is a read, not an interpretation -- but a second place to write a fact is a
# second place for it to go stale, which is exactly what happened to the
# chapter table and the approval log.  So it is checked against the same source
# the approval check above derives from, not trusted on its own.
FM_PHASE  = ('in_progress', 'awaiting_approval', 'done')

def _front_matter(path):
    lines = open(path, encoding='utf-8').read().split('\n')
    if not lines or lines[0].strip() != '---': return None
    try: end = lines.index('---', 1)
    except ValueError: return None
    fm = {}
    for l in lines[1:end]:
        m = re.match(r'^([a-z_]+):\s*(.*)$', l)
        if m: fm[m.group(1)] = m.group(2).strip()
    return fm


# ------------------------------------------------------------- grade columns
# CLAUDE.md forbids the grade codes (K0-K3, L0-L4, A-D) in the CHAT and in the
# book, and requires them IN THESE FILES.  The second half is the one that
# needs a checker: having been told to speak plainly to the user, the natural
# next mistake is to write "정확히 진술하고 적용할 수 있는 수준" into the K
# column too.  Three things break the moment that happens --
#
#   - the depth table (usage x K -> L) is a lookup table and stops resolving;
#   - the "do not re-explain anything at K2 or above" rule of Phase 4 reads
#     this column mechanically;
#   - a sentence in a cell breaks the table itself.
#
# Two rules, in a column whose header is one of GRADE_COLS:
#
#   a. the cell must still CONTAIN its code -- a K in a K column, an L in a
#      depth column, a letter in the usage column -- or be one of the few
#      words that stand in for a code (baseline, 인용, 재사용, ...);
#   b. the cell must not carry the chat-side gloss of that code.
#
# Both halves are needed and neither alone is enough.  (a) alone passes
# "K2 — 정확히 진술하고 적용할 수 있는 수준", which is the very thing the rule
# forbids; (b) alone passes a cell where the code was simply replaced.
#
# What is NOT flagged, because all of it is real and sanctioned usage: a short
# qualifier ("K2 이상", "K2 (자기지정)"), a bolded code, a decision-table
# exception spelled out at length ("표에 따르면 **L3**, 채택값 **L4** (...)"),
# and the stand-in words above.  The check is aimed at ONE defect -- the code
# turning into prose -- not at cell style.
#
# Only project files are checked.  CLAUDE.md and PHASE1_PROBE_GUIDE.md DEFINE
# the codes and gloss them in prose tables on purpose.
# Both templates use this same file, so every heading and vocabulary below is
# listed in BOTH languages.  Source-en/ differs from Source/ only in the MD
# list at the top; if a check is keyed to Korean strings alone it silently
# passes everything in an English project -- which is worse than not having it.
_USAGE = r'(?<![A-Za-z])[A-D](?![A-Za-z])'
_K, _L = r'K[0-3]', r'L[0-4]'
GRADE_COLS = {'사용 방식': _USAGE, 'Usage'         : _USAGE,
              '직접'     : _K,     'Direct'        : _K,
              '추정'     : _K,     'Inferred'      : _K,
              '추정 K'   : _K,     'Inferred K'    : _K,
              '확정 K'   : _K,     'Final K'       : _K,
              '깊이'     : _L,     'Depth'         : _L,
              '확정 깊이': _L,     'Final depth'   : _L,
              '제안 깊이': _L,     'Proposed depth': _L}
GRADE_WORDS = ('baseline', '논문 고유', '인용', '재사용', '해당 없음', '없음',
               'n/a', '미정', '상속', '추정', 'probe', '자기지정',
               'paper-specific', 'inherited', 'estimated', 'self-assigned',
               'undecided', 'none')
GRADE_GLOSS = re.compile(
    '들어본 적|처음 보는|진술을 알아|정확히 진술|증명을 재구성|증명까지 재구성|'
    '진술과 출처만|싣지 않|예와 계산까지|진술만 갖다|가설을 확인해|'
    '증명 기법 자체를 흉내|배경으로 언급|'
    # the English side of the same correspondence table
    'Never heard of it|Recogni[sz]es the statement|Can state it precisely|'
    'reconstruct the proof|statement and its source only|Not included|'
    'examples and computations|Only the statement is borrowed|'
    'checking the hypotheses|proof technique itself|Mentioned as background')

for f in MD:
    if not os.path.exists(f) or f.startswith('../'): continue
    lines = open(f, encoding='utf-8').read().split('\n')
    i = 0
    while i < len(lines):
        if not (re.match(r'^\s*\|.*\|\s*$', lines[i]) and i + 1 < len(lines)
                and re.match(r'^\s*\|[\s:|-]+\|\s*$', lines[i + 1])):
            i += 1
            continue
        head = [c.strip().strip('*` ') for c in
                lines[i].strip().strip('|').split('|')]
        watch = [(k, GRADE_COLS[h]) for k, h in enumerate(head)
                 if h in GRADE_COLS]
        j = i + 2
        while j < len(lines) and re.match(r'^\s*\|', lines[j]):
            cells = [c.strip() for c in lines[j].strip().strip('|').split('|')]
            for k, pat in watch:
                if k >= len(cells): continue
                v = cells[k].strip('*` ')
                if v in ('', '-', '--', '—', '–'): continue
                if GRADE_GLOSS.search(v):
                    bad('grade', f'{f}:{j+1}',
                        f'{head[k]}: gloss beside the code -- {v[:40]}')
                elif not re.search(pat, v) and not any(w in v.lower()
                                                       for w in GRADE_WORDS):
                    bad('grade', f'{f}:{j+1}',
                        f'{head[k]}: no code in cell -- {v[:40]}')
            j += 1
        i = j


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
def _APPROVED_CELL(line):
    # the cell must be exactly the word, so "승인 대기" / "awaiting approval"
    # in a longer cell never counts as an approval
    return _re.search(r'\|\s*(?:승인|Approved)\s*\|', line)
def _approved(cell):
    c = cell.lower()
    if '대기' in cell or 'awaiting' in c or 'pending' in c: return False
    return ('승인' in cell) or ('approved' in c) or ('☑' in cell)
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
                and (_re.search(r'\|\s*(?:신규|new)\s*\|', _l, _re.I)
                     or 'import:' in _l):
            if _approved(_c[-1]):
                _ticked.add(_c[0])
        _m2 = _re.search(r'\*\*`?Ch(\d{2})`?\*\*', _l)
        if _m2 and _APPROVED_CELL(_l):
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
        if _m4 and _APPROVED_CELL(_l):
            _slogged.add(_m4.group(1))
        _m5 = _re.search(r'\*\*`?P(\d{1,2})([ab]?)`?\*\*', _l)
        if _m5 and _APPROVED_CELL(_l):
            _slogged.add(f'{int(_m5.group(1)):02d}{_m5.group(2)}')
    for _s in sorted(_sticked - _slogged):
        issues.append(('approval', f'{_prog}',
                       f'sec{_s} is approved in the reading table but has no '
                       f'approval-log row'))
    for _s in sorted(_slogged - _sticked):
        issues.append(('approval', f'{_prog}',
                       f'sec{_s} is in the approval log but not approved in '
                       f'the reading table'))

    # ---- state block, checked against the log the rule above already trusts
    _fm = _front_matter(_prog)
    if _fm is None:
        bad('state', _prog, 'no YAML state block at the top of the file')
    else:
        for _k in ('phase', 'phase_status', 'last_approved', 'next_action',
                   'chapters_approved', 'sections_approved'):
            if _k not in _fm:
                bad('state', _prog, f'state block is missing "{_k}"')
        _ph = _fm.get('phase', '')
        if not _re.fullmatch(r'[0-6]', _ph):
            bad('state', _prog, f'phase must be 0-6, found "{_ph}"')
        _st = _fm.get('phase_status', '')
        if _st and _st not in FM_PHASE:
            bad('state', _prog,
                f'phase_status must be one of {"/".join(FM_PHASE)}, found "{_st}"')
        # The prose bullet restates the phase for a human; it must at least
        # mention the canonical number, or the two are telling different stories.
        for _l in _txt.split('\n'):
            if (_l.startswith('- 현재 Phase:')
                    or _l.startswith('- Current phase:')) \
                    and _ph and _ph not in _l:
                bad('state', _prog,
                    f'state block says phase {_ph}, but the "current phase" '
                    f'line does not mention it')
        _fmch = set(_re.findall(r'\d{2}', _fm.get('chapters_approved', '')))
        _fmsec = set(_re.findall(r'\d{2}[ab]?', _fm.get('sections_approved', '')))
        for _ch in sorted(_fmch - _logged):
            bad('state', _prog,
                f'Ch{_ch} is in chapters_approved but not in the approval log')
        for _ch in sorted(_logged - _fmch):
            bad('state', _prog,
                f'Ch{_ch} is approved in the log but missing from chapters_approved')
        for _s in sorted(_fmsec - _slogged):
            bad('state', _prog,
                f'sec{_s} is in sections_approved but not in the approval log')
        for _s in sorted(_slogged - _fmsec):
            bad('state', _prog,
                f'sec{_s} is approved in the log but missing from sections_approved')

print('== md files checked ==')
for f in MD:
    if os.path.exists(f): print('  ' + f.replace('../', ''))
print(f'== .aux files read: {len(AUX)}; numbered items: {len(num2lab)} ==')
# A checker that reports "0" without saying what it looked at is how the
# preface and the appendices went unchecked for a whole phase.  Say the counts.
print(f'== SSOT tables: {len(canon)} canonical, {len(copies)} copies '
      f'({", ".join(sorted(canon)) or "none"}) ==')
if not AUX:
    print('  WARNING: no .aux found -- run tex/check.sh first, xrefs unchecked')

for kind in ('macro', 'pipe', 'table', 'math', 'xref', 'escape', 'approval',
             'grade', 'state', 'ssot'):
    hits = [x for x in issues if x[0] == kind]
    print(f'  {LABEL[kind]:<46} {len(hits)}')
    for _, where, what in hits:
        print(f'      {where}  {what}')

print('== result ==')
print(f'  {len(issues)} issue(s)')
sys.exit(1 if issues else 0)
PY
