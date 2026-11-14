#!/bin/sh
# Render each concept at 16, 32 and 256 px, on white and on #0d1117.
# Writes <concepts folder>/preview.png: one row per concept and background.
# Usage: preview.sh <concepts folder>
set -eu
dir=${1:?usage: preview.sh <concepts folder>}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
rows=""
for n in 1 2 3; do
  for bg in white '#0d1117'; do
    tag="$n-$(echo "$bg" | tr -d '#')"
    cells=""
    for px in 16 32 256; do
      cell="$tmp/$tag-$px.png"
      rsvg-convert -w "$px" -h "$px" "$dir/$n.svg" -o "$cell"
      magick "$cell" -background "$bg" -gravity center -extent 272x272 -flatten "$cell"
      cells="$cells $cell"
    done
    # shellcheck disable=SC2086
    magick $cells +append "$tmp/row-$tag.png"
    rows="$rows $tmp/row-$tag.png"
  done
done
# shellcheck disable=SC2086
magick $rows -append "$dir/preview.png"
echo "$dir/preview.png"
