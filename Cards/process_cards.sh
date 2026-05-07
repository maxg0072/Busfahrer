#!/bin/bash
# Process king card images: remove white background, resize, add to asset catalog

RAW_DIR="$(dirname "$0")/Raw"
PROCESSED_DIR="$(dirname "$0")/Processed"
ASSETS_DIR="$(dirname "$0")/../Busfahrer/Assets.xcassets/Cards"

CARD_NAMES=("king_hearts" "king_diamonds" "king_clubs" "king_spades")

for name in "${CARD_NAMES[@]}"; do
    SRC="$RAW_DIR/$name.png"

    if [ ! -f "$SRC" ]; then
        echo "⚠️  Missing: $SRC — skipping"
        continue
    fi

    echo "Processing $name..."

    # Step 1: Remove white background (fuzz 8% tolerance, flood fill from corners)
    convert "$SRC" \
        -alpha set \
        -fuzz 8% \
        -fill none \
        -draw "color 0,0 floodfill" \
        -draw "color 0,%[fx:h-1] floodfill" \
        -draw "color %[fx:w-1],0 floodfill" \
        -draw "color %[fx:w-1],%[fx:h-1] floodfill" \
        "$PROCESSED_DIR/${name}_nobg.png"

    # Step 2: Trim transparent edges, then resize to fit 375x525 keeping aspect ratio
    convert "$PROCESSED_DIR/${name}_nobg.png" \
        -trim \
        -resize 375x525 \
        -gravity center \
        -extent 375x525 \
        "$PROCESSED_DIR/${name}.png"

    echo "  ✅ $name.png — done"

    # Step 3: Create imageset in asset catalog
    IMAGESET_DIR="$ASSETS_DIR/$name.imageset"
    mkdir -p "$IMAGESET_DIR"

    # Copy as @3x image
    cp "$PROCESSED_DIR/${name}.png" "$IMAGESET_DIR/${name}@3x.png"

    # Write Contents.json
    cat > "$IMAGESET_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "${name}@3x.png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : false,
    "template-rendering-intent" : "original"
  }
}
EOF

    echo "  📦 Asset catalog entry created: $name"
done

echo ""
echo "Done! Check $ASSETS_DIR for results."
