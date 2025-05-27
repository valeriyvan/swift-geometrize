#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 source_image [destination_folder]"
    echo "If destination_folder is not provided, results will be stored in the source image folder."
    exit 1
fi

# Source image path
SOURCE_IMAGE="$1"
SOURCE_DIR=$(dirname "$SOURCE_IMAGE")
SOURCE_NAME=$(basename "$SOURCE_IMAGE")
SOURCE_BASE="${SOURCE_NAME%.*}"

# Destination directory (use source directory if not provided)
DEST_DIR="${2:-$SOURCE_DIR}"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Shape types to process
SHAPE_TYPES=("Rectangle" "RotatedRectangle" "Circle" "Ellipse" "RotatedEllipse" "Triangle" "Line" "Polyline" "QuadraticBezier")

# Process with each shape type
for shape in "${SHAPE_TYPES[@]}"; do
    # Define output files for both SVG and PNG
    SVG_OUTPUT="$DEST_DIR/$SOURCE_BASE-$shape.svg"
    PNG_OUTPUT="$DEST_DIR/$SOURCE_BASE-$shape.png"

    echo "Processing with $shape shapes..."

    # Generate SVG output
    echo "  Generating SVG: $SVG_OUTPUT"
    swift run -c release geometrize -i "$SOURCE_IMAGE" -t "$shape" -c 1000 -o "$SVG_OUTPUT"

    # Check if SVG processing was successful
    if [ $? -eq 0 ]; then
        echo "  ✅ Successfully created $SVG_OUTPUT"
    else
        echo "  ❌ Failed to create $SVG_OUTPUT"
        continue  # Skip PNG generation if SVG failed
    fi

    # Generate PNG output
    echo "  Generating PNG: $PNG_OUTPUT"
    swift run -c release geometrize -i "$SOURCE_IMAGE" -t "$shape" -c 1000 -o "$PNG_OUTPUT"

    # Check if PNG processing was successful
    if [ $? -eq 0 ]; then
        echo "  ✅ Successfully created $PNG_OUTPUT"
    else
        echo "  ❌ Failed to create $PNG_OUTPUT"
    fi

    echo "  Completed processing with $shape shapes"
done

echo "All processing complete!"
