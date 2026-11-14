#!/bin/sh
# Self-test for the scripts: a good set passes, a bad set fails, and
# preview and export write their files.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/good" "$tmp/bad"
for n in 1 2 3; do
  echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><circle cx="32" cy="32" r="24" fill="#3b82f6"/></svg>' > "$tmp/good/$n.svg"
done
echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 32"><text>x</text></svg>' > "$tmp/bad/1.svg"

"$here/check-svg.sh" "$tmp/good"
if "$here/check-svg.sh" "$tmp/bad" > "$tmp/bad.log"; then
  echo "check-svg.sh passed a bad set"; exit 1
fi
grep -q "not square" "$tmp/bad.log"
grep -q "text element" "$tmp/bad.log"
grep -q "2.svg: missing" "$tmp/bad.log"

"$here/preview.sh" "$tmp/good" > /dev/null
test -s "$tmp/good/preview.png"
"$here/mockup.sh" "$tmp/good" Test > /dev/null
test -s "$tmp/good/mockup.png"

"$here/export.sh" "$tmp/good/1.svg" "$tmp/assets" > /dev/null
for f in logo.svg logo-16.png logo-512.png favicon.ico; do
  test -s "$tmp/assets/$f"
done

mkdir "$tmp/set"
cp "$tmp/good/1.svg" "$tmp/set/logo-square.svg"
"$here/export.sh" "$tmp/good/1.svg" "$tmp/set-out" "$tmp/set" > /dev/null
for f in logo-square.svg logo-square-512.png; do
  test -s "$tmp/set-out/$f"
done
echo "scripts ok"
