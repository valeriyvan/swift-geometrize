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
    OUTPUT_FILE="$DEST_DIR/$SOURCE_BASE-$shape.svg"
    echo "Processing with $shape shapes: $OUTPUT_FILE"
    swift run -c release geometrize -i "$SOURCE_IMAGE" -t "$shape" -c 1000 -v -o "$OUTPUT_FILE"
    
    # Check if processing was successful
    if [ $? -eq 0 ]; then
        echo "✅ Successfully created $OUTPUT_FILE"
    else
        echo "❌ Failed to create $OUTPUT_FILE"
    fi
done

echo "All processing complete!"