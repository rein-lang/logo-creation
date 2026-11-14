#!/bin/sh
# Show each concept where a logo lives: a round avatar, a site header on
# dark and on light, and a 16 px favicon in a browser tab.
# Writes <concepts folder>/mockup.png: one row per SVG in the folder.
# Usage: mockup.sh <concepts folder> [name]
set -eu
if [ $# -lt 1 ]; then echo "usage: mockup.sh <concepts folder> [name]"; exit 2; fi
dir=$1
name=${2:-Project}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
magick -size 160x160 xc:none -fill white -draw "circle 80,80 80,1" "$tmp/mask.png"
rows=""
for svg in "$dir"/*.svg; do
  n=$(basename "$svg" .svg)
  # Round avatar. Flatten in its own command: a -compose mode set earlier
  # in the same command also applies to -extent and masks the result.
  rsvg-convert -w 160 -h 160 -b white "$svg" -o "$tmp/a.png"
  magick "$tmp/a.png" -alpha set "$tmp/mask.png" -compose DstIn -composite "$tmp/c.png"
  magick "$tmp/c.png" -background '#d0d7de' -flatten -gravity center -extent 200x200 "$tmp/$n-av.png"
  # Header on dark and on light.
  rsvg-convert -w 40 -h 40 "$svg" -o "$tmp/i.png"
  for pair in '0c1018:e6edf5' 'f7f9fb:0f1722'; do
    bg=${pair%%:*}; fg=${pair#*:}
    magick -size 300x200 "xc:#$bg" "$tmp/i.png" -gravity west -geometry +30+0 -composite \
      -fill "#$fg" -font "${MOCKUP_FONT:-/System/Library/Fonts/Supplemental/Arial.ttf}" -pointsize 30 -annotate +80+0 "$name" "$tmp/$n-h$bg.png"
  done
  # 16 px favicon in a tab.
  rsvg-convert -w 16 -h 16 "$svg" -o "$tmp/f.png"
  magick -size 200x200 'xc:#dee1e6' -fill white -draw "roundrectangle 10,80 190,120 8,8" \
    "$tmp/f.png" -gravity west -geometry +22+0 -composite \
    -fill '#333333' -font "${MOCKUP_FONT:-/System/Library/Fonts/Supplemental/Arial.ttf}" -pointsize 14 -annotate +46+0 "$name" "$tmp/$n-fav.png"
  magick -size 70x200 xc:'#666666' -fill white -gravity center -font "${MOCKUP_FONT:-/System/Library/Fonts/Supplemental/Arial.ttf}" -pointsize 26 -annotate +0+0 "$n" "$tmp/$n-label.png"
  magick "$tmp/$n-label.png" "$tmp/$n-av.png" "$tmp/$n-h0c1018.png" "$tmp/$n-hf7f9fb.png" "$tmp/$n-fav.png" +append "$tmp/row-$n.png"
  rows="$rows $tmp/row-$n.png"
done
# shellcheck disable=SC2086
magick $rows -append "$dir/mockup.png"
echo "$dir/mockup.png"
