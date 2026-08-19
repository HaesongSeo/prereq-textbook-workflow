#!/bin/sh
# check.sh -- clean-room build and verification.
#
# Why this exists: the TeX log must be inspected with `grep -a`. If any file
# under tex/ contains non-ASCII, main.log is classified as binary and a plain
# grep silently reports nothing -- which once caused a broken build to be
# reported as clean. Run this, not an ad-hoc grep.
#
# Usage:  sh check.sh
set -e
cd "$(dirname "$0")"

echo "== 1. non-ASCII scan (must be empty) =="
found=0
for f in $(find . -name '*.tex' -o -name '*.sty' -o -name '*.bib' | sort); do
  [ -f "$f" ] || continue
  n=$(LC_ALL=C grep -c '[^ -~	]' "$f" || true)
  if [ "$n" != "0" ]; then printf '  %-42s %s line(s)\n' "$f" "$n"; found=1; fi
done
[ "$found" = "0" ] && echo "  clean"

echo "== 2. clean-room build =="
latexmk -C >/dev/null 2>&1 || true
find . -name '*.aux' -delete
if latexmk -pdf -interaction=nonstopmode main.tex >/dev/null 2>&1; then
  echo "  latexmk exit 0"
else
  echo "  latexmk FAILED (exit $?)"
fi

echo "== 3. log inspection (grep -a) =="
for pat in '^!' 'LaTeX Warning' 'Package .* Warning' 'Missing character' \
           '^Overfull' '^Underfull'; do
  n=$(grep -ace "$pat" main.log || true)
  printf '  %-24s %s\n' "$pat" "$n"
done

echo "== 4. chapter summary tables =="
# progress.md calls the closing "Summary: where this chapter is used" table the
# tool of the chapter check: every numbered item above must appear in it, and
# each row must point at where the item is used.  Nothing enforced that, and a
# book written to the same template dropped the table from all twelve of its
# chapters -- replacing it with a prose remark, which reads well and cannot be
# checked.  An item missing from the table is an item nobody has shown a use
# for, which is exactly what Phase 4 says to delete or to justify.
python3 - <<'PY' || true
import re, glob, os
KIND = r'(?:thm|prop|lem|cor|def|defn|ex|rem|rmk|conv)'
# Recursive, per CLAUDE.md: a checker sees only what its glob names, so a
# chapter filed into a subdirectory must not fall outside it.
files = [f for f in sorted(glob.glob('chapters/**/*.tex', recursive=True))
         if not os.path.basename(f).startswith('ch00-')]   # ch00 is the template
missing_total = notable = 0
for f in files:
    src = open(f, encoding='utf-8', errors='replace').read()
    m = re.search(r'\\section\{Summary[^}]*\}', src)
    if not m:
        print(f'  {f}: no "Summary" section')
        notable += 1
        continue
    body, table = src[:m.start()], src[m.start():]
    items = re.findall(r'\\label\{(' + KIND + r':[^}]*)\}', body)
    shown = set(re.findall(r'\\(?:ref|Cref|cref|autoref)\{([^}]*)\}', table))
    gaps  = [i for i in items if i not in shown]
    if gaps:
        print(f'  {f}: {len(gaps)}/{len(items)} not in the table -- '
              + ', '.join(gaps[:6]) + (' ...' if len(gaps) > 6 else ''))
        missing_total += len(gaps)
print(f'  {len(files)} chapter file(s); {notable} without a summary table; '
      f'{missing_total} item(s) missing from a table')
PY

echo "== 5. result =="
if [ -f main.pdf ]; then
  echo "  main.pdf: $(pdfinfo main.pdf | awk '/^Pages/{print $2}') pages"
else
  echo "  main.pdf NOT produced"
fi
grep -a -A6 '^!' main.log | head -20 || true
