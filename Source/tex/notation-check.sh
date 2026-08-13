#!/bin/sh
# Find places where a notation macro's expansion was typed out by hand.
#
# Why: notation.sty exists so that the whole text follows the target paper's
# notation from one place.  A hand-written \mathcal{O} or \mathbb{P} still
# typesets, so nothing complains, but it drifts out of reach of any later
# change and shows up as an inconsistency to the reader.  check.sh cannot
# see this.
#
# This DETECTS ONLY -- it never rewrites.  Some hits are legitimate (the
# macro definitions themselves; a deliberate contrast with another paper's
# notation), so read the list.
#
# Run from the project root:  sh tex/notation-check.sh

cd "$(dirname "$0")/.." || exit 1

python3 - <<'EOF'
import re, glob, os, sys

# Zero-argument macros whose expansion is a fixed string worth policing.
# (Macros taking arguments, like \masso or \cls, cannot be matched this way.)
DEFN = re.compile(r'\\(?:new|renew)command\{\\([A-Za-z]+)\}\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}\s*(?:%.*)?$')

macros = {}
for line in open('tex/notation.sty', errors='ignore'):
    m = DEFN.match(line.strip())
    if m and '#' not in m.group(2):
        name, exp = m.group(1), m.group(2).strip()
        if len(exp) >= 6:            # skip trivially short expansions
            macros[name] = exp

if not macros:
    sys.exit('no zero-argument macros parsed out of tex/notation.sty')

print('== policing %d expansions ==' % len(macros))
for n, e in sorted(macros.items()):
    print('   \\%-8s ->  %s' % (n, e))
print()

# Deliberate exceptions, reviewed 2026-08-08.  Keyed by (file, macro) with the
# reason, so that a clean run means "no new drift" rather than "nothing to
# report ever".  Adding a line here is a decision, not a silencing.
ACCEPTED = {
 # ('ch07-demailly-semple-tower.tex', 'tX'):
 #   'the subscript sits outside the tilde, as the paper prints it',
}

hits = ok = 0
accepted_seen = set()
for f in sorted(glob.glob('tex/chapters/*.tex')) + sorted(glob.glob('tex/paper/*.tex')):
    base = os.path.basename(f)
    for i, raw in enumerate(open(f, errors='ignore')):
        line = raw.split('%')[0]
        for name, exp in sorted(macros.items()):
            for m in re.finditer(re.escape(exp), line):
                s = max(0, m.start() - 30)
                ctx = line[s:m.end() + 30].strip()
                if (base, name) in ACCEPTED:
                    ok += 1
                    accepted_seen.add((base, name))
                    print('  accepted      %s:%d  %s' % (f, i + 1, ctx))
                else:
                    hits += 1
                    print('  HAND-WRITTEN  %s:%d  %s  (use \\%s)' % (f, i + 1, ctx, name))

if accepted_seen:
    print()
    print('== accepted exceptions ==')
    for k in sorted(accepted_seen):
        print('  %s / \\%s: %s' % (k[0], k[1], ACCEPTED[k]))
stale = set(ACCEPTED) - accepted_seen
for k in sorted(stale):
    print('  note: exception %s / \\%s no longer fires; drop it' % k)

print('== result ==')
print('  hand-written expansions  %d' % hits)
print('  accepted exceptions      %d' % ok)
sys.exit(1 if hits else 0)
EOF
