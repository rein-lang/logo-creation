#!/bin/sh
# Check each logo concept in a folder. Exit 1 and name each failure.
# Usage: check-svg.sh <concepts folder>
set -u
dir=${1:?usage: check-svg.sh <concepts folder>}
fail=0
bad() { echo "$f: $1"; fail=1; }
for n in 1 2 3; do
  f="$dir/$n.svg"
  [ -f "$f" ] || { bad "missing"; continue; }
  xmllint --noout "$f" 2>/dev/null || { bad "not well-formed XML"; continue; }
  # ponytail: regex checks, not a full SVG parser; enough for hand-drawn marks.
  vb=$(grep -o 'viewBox="[^"]*"' "$f" | head -1 | cut -d'"' -f2)
  if [ -z "$vb" ]; then
    bad "no viewBox"
  else
    # shellcheck disable=SC2086
    set -- $vb
    { [ $# -eq 4 ] && [ "$3" = "$4" ]; } || bad "viewBox is not square: $vb"
  fi
  grep -q '<image' "$f" && bad "embedded image; draw shapes instead"
  grep -q '<text' "$f" && bad "text element; fonts differ per machine"
  size=$(wc -c < "$f" | tr -d ' ')
  [ "$size" -le 8192 ] || bad "$size bytes; keep a mark under 8 KB"
  colors=$(grep -oiE '#[0-9a-f]{6}|#[0-9a-f]{3}' "$f" | tr 'A-F' 'a-f' | sort -u | wc -l | tr -d ' ')
  [ "$colors" -le 3 ] || bad "$colors colors; use at most 3"
done
exit $fail
