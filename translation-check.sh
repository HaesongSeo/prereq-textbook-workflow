#!/bin/sh
# translation-check.sh -- detect English translations that have gone stale.
#
# Why this exists: the Korean files are the policy; the .en.md files are a
# translation of them. A translation is a fork with the same failure mode as an
# imported chapter -- the source gets edited and the copy never hears about it,
# silently. Nothing in a diff makes that visible, because the two files never
# looked alike to begin with.
#
# So the same device is used here as in tex/import-check.sh: record the hash of
# the SOURCE at the moment it was translated, and fail when it moves. This does
# not check that the translation is good. It checks that it is not out of date,
# which is the part a machine can actually decide.
#
# It checks a second thing too: the two templates. Source/ and Source-en/ differ
# only in the files that carry PROSE -- the scripts, the .sty files and the .tex
# skeleton must stay byte-identical, or a fix to one template silently misses
# the other.
#
# "Prose" is not the same as ".md". IMPORTS and IMPORT-HEADER.txt are documents
# that happen not to carry that extension, and they get translated like any
# other document; comparing them byte-for-byte would fail the moment they were.
# They are listed in TRANSLATIONS instead, with the rows above.
# The one legitimate difference (md-check.sh points at its own language's root
# policy files) is normalised away rather than allowed as a line count, so that
# any OTHER difference still fails.
#
# Usage:  sh translation-check.sh        (from the Study root)
set -e
cd "$(dirname "$0")"

[ -f TRANSLATIONS ] || { echo "== no TRANSLATIONS: nothing is translated =="; exit 0; }

echo "== translations =="
fail=0
n=0
while IFS='|' read -r trans src recorded date; do
  case "$trans" in ''|\#*) continue ;; esac
  trans=$(echo "$trans"       | sed 's/^ *//; s/ *$//')
  src=$(echo "$src"           | sed 's/^ *//; s/ *$//')
  recorded=$(echo "$recorded" | sed 's/^ *//; s/ *$//')
  date=$(echo "$date"         | sed 's/^ *//; s/ *$//')
  n=$((n+1))

  if [ ! -f "$trans" ]; then
    echo "  MISSING        $trans"; fail=1; continue
  fi
  if [ ! -f "$src" ]; then
    echo "  SOURCE GONE    $src  (moved or renamed; update TRANSLATIONS)"
    fail=1; continue
  fi

  now=$(shasum -a 256 "$src" | awk '{print $1}')
  if [ "$now" = "$recorded" ]; then
    printf '  ok             %-34s source unchanged since %s\n' "$trans" "$date"
  else
    echo "  STALE          $trans"
    echo "                 source:      $src"
    echo "                 translated:  $recorded ($date)"
    echo "                 now:         $now"
    echo "                 Re-translate what changed, then update the hash:"
    echo "                   shasum -a 256 \"$src\""
    fail=1
  fi
done < TRANSLATIONS

echo "== template parity (Source/ vs Source-en/) =="
KO=Source
EN=Source-en
p=0
if [ ! -d "$EN" ]; then
  echo "  no $EN: nothing to compare"
else
  # Everything that is not a .md (those are the translations, checked above) and
  # not a build artefact. Keep this find recursive: a file added to a new
  # subdirectory must not fall outside the comparison.
  for f in $(cd "$KO" && find . -type f \
        ! -name '*.md' ! -name '.DS_Store' \
        ! -name 'IMPORTS' ! -name 'IMPORT-HEADER.txt' \
        ! -name '*.aux' ! -name '*.bbl' ! -name '*.blg' ! -name '*.fdb_latexmk' \
        ! -name '*.fls' ! -name '*.log' ! -name '*.out' ! -name '*.toc' \
        ! -name '*.pdf' ! -name '*.synctex.gz' | sort); do
    p=$((p+1))
    if [ ! -f "$EN/$f" ]; then
      echo "  MISSING        $EN/${f#./}"
      fail=1; continue
    fi
    # Normalise the one difference that is meant to exist, then require an
    # exact match. Anything else -- a fix applied to one template only -- fails.
    #
    # A consequence worth knowing: a shared file must not name CLAUDE.en.md
    # (or the other two) even when both copies name it identically, because
    # only the English copy gets rewritten and the two then differ. Refer to
    # the policy file without its language suffix instead.
    if ! sed -e 's/CLAUDE\.en\.md/CLAUDE.md/g' \
             -e 's/PHASE1_PROBE_GUIDE\.en\.md/PHASE1_PROBE_GUIDE.md/g' \
             -e 's/README\.en\.md/README.md/g' "$EN/$f" \
         | diff -q - "$KO/$f" >/dev/null 2>&1; then
      echo "  DIVERGED       ${f#./}"
      echo "                 diff \"$KO/${f#./}\" \"$EN/${f#./}\""
      fail=1
    fi
  done
  # A file that exists only on the English side is drift too.
  for f in $(cd "$EN" && find . -type f \
        ! -name '*.md' ! -name '.DS_Store' \
        ! -name 'IMPORTS' ! -name 'IMPORT-HEADER.txt' \
        ! -name '*.aux' ! -name '*.bbl' ! -name '*.blg' ! -name '*.fdb_latexmk' \
        ! -name '*.fls' ! -name '*.log' ! -name '*.out' ! -name '*.toc' \
        ! -name '*.pdf' ! -name '*.synctex.gz' | sort); do
    [ -f "$KO/$f" ] || { echo "  EXTRA          $EN/${f#./}  (not in $KO)"; fail=1; }
  done
  echo "  files compared   $p"
fi

echo "== result =="
echo "  translations     $n"
[ "$fail" = "0" ] && echo "  stale / drift    0" || echo "  stale / drift    see above"
exit $fail
