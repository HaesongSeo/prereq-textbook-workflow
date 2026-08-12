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

echo "== 4. result =="
if [ -f main.pdf ]; then
  echo "  main.pdf: $(pdfinfo main.pdf | awk '/^Pages/{print $2}') pages"
else
  echo "  main.pdf NOT produced"
fi
grep -a -A6 '^!' main.log | head -20 || true
