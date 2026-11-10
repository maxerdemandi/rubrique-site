#!/usr/bin/env bash
# Downloads the logo, favicon, headshots, and photos from the current
# Squarespace site into assets/img/, then resizes them for the web.
#
# Run this ONCE, from the repository folder, BEFORE you cancel Squarespace:
#   bash scripts/fetch-images.sh
#
# Works on macOS out of the box (uses curl and the built-in `sips` tool).

set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p assets/img
cd assets/img

BASE="https://images.squarespace-cdn.com/content/v1/6a7f51d66fa78e79452c7d6a"

get () {  # get <output-file> <path-after-BASE>
  echo "  downloading $1"
  curl -fsSL --retry 3 -o "$1" "$BASE/$2"
}

echo "Fetching images from Squarespace CDN..."
get logo.png               "f648e827-b730-4816-aa67-d51a37dcd190/logo.png?format=1500w"
get favicon-src.png        "7780b0f5-1bfe-4d7b-8080-c4f238484e1b/favicon.ico"
get team-max-erdemandi.jpg "d87925f1-bee9-4e9e-9966-a0fe0ecb1177/max-13.jpg?format=750w"
get team-lahne-mattas-curry.jpg "be264827-3e39-4a72-a3cc-69e6d085421e/IMG_3756.jpg?format=750w"
get team-max-groznik-src.png    "d1583038-3f32-41be-9166-6e2b1c16c69a/View+recent+photos.png?format=750w"
get home-hero.jpg          "1787598484008-PYFK1L0OJX586SRGXOJV/unsplash-image-o9olH5LziVg.jpg?format=2500w"
get home-hands.jpg         "1787003295234-3D995IKPTE5RZKU04YWD/unsplash-image-lyiKExA4zQA.jpg?format=1500w"
get home-data.jpg          "1787334506907-HZ4ZTG25UPJ5PKJLVFP6/unsplash-image-9PwLeZA-RGc.jpg?format=2500w"
get services-hero.jpg      "1787622549774-U4ZF9TZ2L0EW9762AIXD/unsplash-image-Xg-ut7qtJiM.jpg?format=2500w"
get services-data.jpg      "1787065744931-53QPB1NA54K5OFA47TP8/unsplash-image-XrIfY_4cK1w.jpg?format=1500w"
get team-hero.jpg          "1787605168586-9GTJ5F0NPURY4L383BH0/unsplash-image-1FI2QAYPa-Y.jpg?format=2500w"
get about-hero.jpg         "1787069176931-PA3NREA9P55APY0VHL4Q/unsplash-image-lN1fPT9J6DA.jpg?format=2500w"
get about-1.jpg            "1787610029237-PNNNFW9NBU2QGTLANTVT/unsplash-image-DSuQmFV3SD0.jpg?format=1500w"
get about-2.jpg            "1787608766143-CG2BNKRE5I374VJF9R39/unsplash-image-9HI8UJMSdZA.jpg?format=1500w"
get about-3.jpg            "1787608927482-P1YKL2XYYQC5IZQZYM1U/unsplash-image-46juD4zY1XA.jpg?format=1500w"
get about-4.jpg            "1787608591547-BZUKJFP7YA59530WPRBE/unsplash-image--V4vaZVooxQ.jpg?format=1500w"

echo "Resizing and converting..."
if command -v sips >/dev/null 2>&1; then
  # Favicon: 512 px PNG.
  sips -s format png -Z 512 favicon-src.png --out favicon.png >/dev/null
  # Groznik headshot arrives as PNG; store as JPEG to match the others.
  sips -s format jpeg team-max-groznik-src.png --out team-max-groznik.jpg >/dev/null
  # Large background photos: cap at 2000 px on the long edge.
  for f in home-hero.jpg home-data.jpg services-hero.jpg team-hero.jpg about-hero.jpg; do
    sips -Z 2000 "$f" >/dev/null
  done
  # Social-share preview image (1200 px wide).
  sips -Z 1200 home-hero.jpg --out og-image.jpg >/dev/null
elif command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
  IM=$(command -v magick || command -v convert)
  "$IM" favicon-src.png -resize 512x512 favicon.png
  "$IM" team-max-groznik-src.png team-max-groznik.jpg
  for f in home-hero.jpg home-data.jpg services-hero.jpg team-hero.jpg about-hero.jpg; do
    "$IM" "$f" -resize '2000x2000>' "$f"
  done
  "$IM" home-hero.jpg -resize 1200x og-image.jpg
else
  echo "  No image tool found; copying files without resizing."
  cp favicon-src.png favicon.png
  cp team-max-groznik-src.png team-max-groznik.jpg   # browsers sniff the real format
  cp home-hero.jpg og-image.jpg
fi

rm -f favicon-src.png team-max-groznik-src.png

echo "Done. Files in assets/img:"
ls -lh
