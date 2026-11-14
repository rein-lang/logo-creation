#!/bin/sh
# Save the picked concept as the project's logo files.
# Writes logo.svg, logo-<size>.png and favicon.ico to the output folder.
# With a set folder, also copies each *.svg in it and renders it at 512 px.
# Usage: export.sh <concept svg> <output folder> [set folder]
set -eu
svg=${1:?usage: export.sh <concept svg> <output folder> [set folder]}
out=${2:?usage: export.sh <concept svg> <output folder> [set folder]}
set_dir=${3:-}
mkdir -p "$out"
cp "$svg" "$out/logo.svg"
for px in 16 32 48 180 192 512; do
  rsvg-convert -w "$px" -h "$px" "$svg" -o "$out/logo-$px.png"
done
magick "$out/logo-16.png" "$out/logo-32.png" "$out/logo-48.png" "$out/favicon.ico"
if [ -n "$set_dir" ]; then
  for f in "$set_dir"/*.svg; do
    n=$(basename "$f" .svg)
    cp "$f" "$out/$n.svg"
    rsvg-convert -w 512 -h 512 "$f" -o "$out/$n-512.png"
  done
fi
ls "$out"
