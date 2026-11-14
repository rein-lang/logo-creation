#!/bin/sh
# Save the picked concept as the project's logo files.
# Writes logo.svg, logo-<size>.png and favicon.ico to the output folder.
# Usage: export.sh <concept svg> <output folder>
set -eu
svg=${1:?usage: export.sh <concept svg> <output folder>}
out=${2:?usage: export.sh <concept svg> <output folder>}
mkdir -p "$out"
cp "$svg" "$out/logo.svg"
for px in 16 32 48 180 192 512; do
  rsvg-convert -w "$px" -h "$px" "$svg" -o "$out/logo-$px.png"
done
magick "$out/logo-16.png" "$out/logo-32.png" "$out/logo-48.png" "$out/favicon.ico"
ls "$out"
