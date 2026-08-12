#!/bin/sh
# import-check.sh -- detect drift in chapters forked from another project.
#
# Why this exists: a chapter borrowed from a sibling project is a FORK, not a
# copy. It cannot be verbatim -- the origin refers into its own book's chapters
# and cites its own target paper -- so it gets adapted on the way in. From then
# on the two diverge silently: the origin can be corrected and this copy will
# never hear about it.
#
# This turns that silence into a failing check. It does NOT merge anything.
# When it reports drift, read the diff and decide; the ADAPTED list in the
# file's provenance block is the recipe for re-applying the changes.
#
# The rule (CLAUDE.md, "교차 프로젝트 재사용"): the ORIGIN is authoritative for
# the mathematics. Fix the origin first, then re-import.
#
# Usage:  sh tex/import-check.sh        (from the project root)
set -e
cd "$(dirname "$0")/.."

[ -f tex/IMPORTS ] || { echo "== no tex/IMPORTS: nothing is imported =="; exit 0; }

echo "== imported chapters =="
fail=0
n=0
while IFS='|' read -r local origin recorded date; do
  case "$local" in ''|\#*) continue ;; esac
  local=$(echo "$local"   | sed 's/^ *//; s/ *$//')
  origin=$(echo "$origin" | sed 's/^ *//; s/ *$//')
  recorded=$(echo "$recorded" | sed 's/^ *//; s/ *$//')
  date=$(echo "$date"     | sed 's/^ *//; s/ *$//')
  n=$((n+1))

  if [ ! -f "tex/$local" ]; then
    echo "  MISSING LOCAL  tex/$local"; fail=1; continue
  fi
  # the provenance block must survive edits
  if ! grep -q 'IMPORTED CHAPTER' "tex/$local"; then
    echo "  NO PROVENANCE  tex/$local  (the '% IMPORTED CHAPTER' block was lost)"
    fail=1
  fi
  if [ ! -f "$origin" ]; then
    echo "  ORIGIN GONE    $origin"
    echo "                 (moved or renamed; update tex/IMPORTS)"
    fail=1; continue
  fi
  now=$(shasum -a 256 "$origin" | awk '{print $1}')
  if [ "$now" = "$recorded" ]; then
    printf '  ok             %-34s origin unchanged since %s\n' "$local" "$date"
  else
    echo "  ORIGIN CHANGED $local"
    echo "                 origin:   $origin"
    echo "                 forked:   $recorded ($date)"
    echo "                 now:      $now"
    echo "                 diff \"$origin\" \"tex/$local\""
    fail=1
  fi
done < tex/IMPORTS

echo "== result =="
echo "  imports checked  $n"
[ "$fail" = "0" ] && echo "  drift            0" || echo "  drift            see above"
exit $fail
