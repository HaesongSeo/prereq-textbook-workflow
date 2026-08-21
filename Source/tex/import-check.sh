#!/bin/sh
# import-check.sh -- detect drift in chapters forked from another project.
#
# Why this exists: a chapter borrowed from a sibling project is a FORK, not a
# copy. It cannot be verbatim -- the origin refers into its own book's chapters
# and cites its own target paper -- so it gets adapted on the way in. From then
# on the two diverge silently, in BOTH directions:
#
#   - the origin can be corrected and this copy will never hear about it;
#   - this copy can be edited and nothing records that it now says something
#     the origin does not.
#
# Two hashes catch the two directions. This does NOT merge anything. When it
# reports drift, read the diff and decide; the ADAPTED list in the file's
# provenance block is the recipe for re-applying the changes.
#
# The rule ("정본의 방향" / "The direction of authority", in the shared
# policy file): the ORIGIN is authoritative for the mathematics, but an error found here is corrected HERE and listed under
# FIXED: in the provenance block -- it is not pushed back to the origin. So
# ADAPTED and FIXED are the only things allowed to differ, and both have to be
# written down. This script is what makes "written down" non-optional.
#
# Usage:  sh tex/import-check.sh        (from the project root)
set -e
cd "$(dirname "$0")/.."

[ -f tex/IMPORTS ] || { echo "== no tex/IMPORTS: nothing is imported =="; exit 0; }

echo "== imported chapters =="
# The literal <...> tokens of the provenance template, used below.
PLACEHOLDERS=''
[ -f tex/IMPORT-HEADER.txt ] && \
  PLACEHOLDERS=$(grep -o '<[^<>]*>' tex/IMPORT-HEADER.txt | sort -u)

fail=0
n=0
while IFS='|' read -r local origin recorded localrec date; do
  case "$local" in ''|\#*) continue ;; esac
  local=$(echo "$local"       | sed 's/^ *//; s/ *$//')
  origin=$(echo "$origin"     | sed 's/^ *//; s/ *$//')
  recorded=$(echo "$recorded" | sed 's/^ *//; s/ *$//')
  localrec=$(echo "$localrec" | sed 's/^ *//; s/ *$//')
  date=$(echo "$date"         | sed 's/^ *//; s/ *$//')
  n=$((n+1))

  # A row written in the old four-column format leaves the date empty, because
  # what used to be the date landed in the local-hash column. Say so, rather
  # than skipping the new check in silence.
  if [ -z "$date" ]; then
    echo "  OLD FORMAT     $local"
    echo "                 tex/IMPORTS predates the local-hash column."
    echo "                 add it:   shasum -a 256 \"tex/$local\""
    fail=1; continue
  fi

  if [ ! -f "tex/$local" ]; then
    echo "  MISSING LOCAL  tex/$local"; fail=1; continue
  fi
  # the provenance block must survive edits
  if ! grep -q 'IMPORTED CHAPTER' "tex/$local"; then
    echo "  NO PROVENANCE  tex/$local  (the '% IMPORTED CHAPTER' block was lost)"
    fail=1
  fi

  # ---- direction 1: has the origin moved? ---------------------------------
  if [ ! -f "$origin" ]; then
    echo "  ORIGIN GONE    $origin"
    echo "                 (moved or renamed; update tex/IMPORTS)"
    fail=1
  else
    now=$(shasum -a 256 "$origin" | awk '{print $1}')
    if [ "$now" != "$recorded" ]; then
      echo "  ORIGIN CHANGED $local"
      echo "                 origin:   $origin"
      echo "                 forked:   $recorded ($date)"
      echo "                 now:      $now"
      echo "                 diff \"$origin\" \"tex/$local\""
      fail=1
    fi
  fi

  # ---- direction 2: have WE edited the fork without saying so? ------------
  # The script cannot tell an adaptation from a mathematical correction, and
  # it does not try. It forces a human to say which one it was -- the same
  # way the origin check forces a human to read the diff.
  mine=$(shasum -a 256 "tex/$local" | awk '{print $1}')
  if [ "$mine" != "$localrec" ]; then
    echo "  LOCAL CHANGED  $local"
    echo "                 recorded: $localrec"
    echo "                 now:      $mine"
    echo "                 Record what changed in the provenance block --"
    echo "                 ADAPTED: if it is notation/refs/citations,"
    echo "                 FIXED:   if it corrects the mathematics --"
    echo "                 then update the 4th column of tex/IMPORTS."
    fail=1
  fi

  # ---- the provenance block has to say something -------------------------
  blk=$(sed -n '/IMPORTED CHAPTER/,/^% =\{10,\}$/p' "tex/$local")
  # Match the template's placeholders LITERALLY, taken from IMPORT-HEADER.txt
  # itself. A pattern like <...> cannot be used: mathematics is full of angle
  # brackets, and "n<=2 -> n<=3" matches it. Reading the template also means
  # the check follows the template if its wording changes.
  if [ -n "$PLACEHOLDERS" ]; then
    ph=$(printf '%s\n' "$blk" | grep -c -F "$PLACEHOLDERS" || true)
    if [ "$ph" != "0" ]; then
      echo "  PLACEHOLDER    $local"
      echo "                 $ph line(s) still hold text copied verbatim from"
      echo "                 tex/IMPORT-HEADER.txt."
      fail=1
    fi
  fi
  # FIXED: is optional, but an empty one means the section was left behind
  # rather than filled in -- and an empty FIXED: reads as "nothing was
  # corrected", which is exactly the claim we must not make by accident.
  if printf '%s\n' "$blk" | grep -q '^% *FIXED:'; then
    nf=$(printf '%s\n' "$blk" \
         | sed -n '/^% *FIXED:/,/^% *[A-Z][A-Z]*:/p' \
         | grep -c '^% *-' || true)
    if [ "$nf" = "0" ]; then
      echo "  EMPTY FIXED    $local"
      echo "                 FIXED: has no entries. Drop the section if"
      echo "                 nothing here corrects the origin."
      fail=1
    fi
  fi

  [ "$fail" = "0" ] && \
    printf '  ok             %-30s origin and fork both unchanged since %s\n' \
           "$local" "$date"
done < tex/IMPORTS

echo "== result =="
echo "  imports checked  $n"
[ "$fail" = "0" ] && echo "  drift            0" || echo "  drift            see above"
exit $fail
