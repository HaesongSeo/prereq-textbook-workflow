#!/bin/sh
# style-check.sh -- point at the traces that broken writing rules leave.
#
# Why: PHASE45_WRITING_GUIDE.md sets rules that no build can check -- where a
# symbol is defined, whether a step of a proof is skipped, whether a contrast
# is needed.  This script cannot judge any of that.  It only lists the places
# where those rules are most often broken, so that each one gets read.
#
# It WARNS ONLY and always exits 0.  Every pattern below also has legitimate
# uses (a negative statement a proof needs, a quoted phrase of the source).
# Read every line, then fix it or confirm the reason to keep it
# (PHASE45_WRITING_GUIDE.md, sections 3 and 5).
#
# What it lists:
#   1. contrastive phrases: ", not", "not merely", "not only", "not just",
#      "rather than"                                     (guide, section 3)
#   2. phrases that skip a step: "clearly", "obviously", "it is easy to see",
#      "one checks", "standard argument", "well known", ...   (section 5)
#   3. a notation paragraph (\textbf{Notation...}) and forward references
#      ("introduced below", "defined below", "see below")   (sections 2.1, 2.4)
#   4. "throughout the book" declarations -- compare the list with the
#      conventions section of the first chapter               (section 2.2)
#   5. claims of completeness inside \OWNCHECK{...} or \OWNPROOF{...}:
#      "written out", "all cases", "every case" -- check that it is all there
#                                                              (section 5)
#
# Scope: every .tex under tex/, recursively, except the chapter templates
# (ch00-example*, sec00-example*) and anything under tex/backup/.  The
# templates are matched by their full name: a paper whose introduction is
# section 0 has a real chapter paper/sec00-<slug>.tex.  Comments are not
# scanned.
# Phrases are matched across line breaks.
#
# Run from the project root:  sh tex/style-check.sh

cd "$(dirname "$0")/.." || exit 1

python3 - <<'EOF'
import re, glob, os

CATS = [
    ('contrast', 'contrastive phrases (guide, section 3)', [
        r',\s+not\b', r'\bnot\s+merely\b', r'\bnot\s+only\b', r'\bnot\s+just\b',
        r'\brather\s+than\b']),
    ('skip', 'phrases that skip a step (guide, section 5)', [
        r'\bclearly\b', r'\bobviously\b', r'\bit\s+is\s+easy\s+to\s+(?:see|check)\b',
        r'\beasily\b', r'\bone\s+(?:can\s+)?(?:checks?|verif(?:y|ies)|sees?)\b',
        r'\bstandard\s+argument\b', r'\bwell[- ]known\b', r'\btrivially\b',
        r'\bstraightforward\b', r'\bleft\s+to\s+the\s+reader\b', r'\broutine\b']),
    ('dump', 'notation paragraphs and forward references (guide, sections 2.1, 2.4)', [
        r'\\textbf\{Notation', r'\b(?:introduced|defined)\s+below\b', r'\bsee\s+below\b']),
    ('fixed', '"throughout the book" declarations (guide, section 2.2)', [
        r'\bthroughout\s+(?:the|this)\s+(?:book|textbook)\b']),
]
COMPLETE = re.compile(r'\b(?:written\s+out|all\s+cases|every\s+case)\b', re.I)
MARK = re.compile(r'\\OWN(?:CHECK|PROOF)\s*\{')

def strip_comments(text):
    # Blank out comments, keeping every character position and line number.
    return re.sub(r'(?<!\\)%[^\n]*', lambda m: ' ' * len(m.group(0)), text)

def braced(text, start):
    # text[start] is just past an opening brace; return the end of the group.
    depth = 1
    i = start
    while i < len(text) and depth:
        if text[i] == '{' and text[i - 1] != '\\':
            depth += 1
        elif text[i] == '}' and text[i - 1] != '\\':
            depth -= 1
        i += 1
    return i

files = []
for f in sorted(glob.glob('tex/**/*.tex', recursive=True)):
    if f.startswith('tex/backup/'):
        continue
    if re.match(r'(ch|sec)00-example', os.path.basename(f)):
        continue
    files.append(f)

hits = {key: [] for key, _, _ in CATS}
hits['complete'] = []

for f in files:
    text = strip_comments(open(f, errors='ignore').read())
    lines = text.split('\n')
    def where(pos):
        n = text.count('\n', 0, pos)
        return n + 1, ' '.join(lines[n].split())[:110]
    for key, _, pats in CATS:
        flags = 0 if key == 'dump' else re.I
        seen = set()
        for p in pats:
            for m in re.finditer(p, text, flags):
                ln, ctx = where(m.start())
                if ln not in seen:
                    seen.add(ln)
                    hits[key].append((f, ln, ctx))
    for m in MARK.finditer(text):
        end = braced(text, m.end())
        body = text[m.end():end - 1]
        c = COMPLETE.search(body)
        if c:
            ln, ctx = where(m.end() + c.start())
            hits['complete'].append((f, ln, ctx))

labels = [(key, title) for key, title, _ in CATS]
labels.append(('complete', 'claims of completeness inside verification marks (guide, section 5)'))

print('== style-check: warnings only, never fails ==')
print('  files scanned  %d' % len(files))
for n, (key, title) in enumerate(labels, 1):
    print('== %d. %s ==' % (n, title))
    for f, ln, ctx in sorted(hits[key]):
        print('  %s:%d  %s' % (f, ln, ctx))
print('== result ==')
for key, title in labels:
    print('  %-9s %d' % (key, len(hits[key])))
print('  (warnings: read each one; fix it or confirm why it stays)')
EOF
exit 0
