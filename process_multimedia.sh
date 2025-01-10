#!/bin/bash

# Check if directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

DIRECTORY=$1

# Compress videos using ffmpeg
find "$DIRECTORY" -type f | while IFS= read -r video; do
    # Check if the file is a video
    if ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$video" > /dev/null 2>&1; then
        output="${video%.*}_compressed.mp4"
        if [ ! -f "$output" ]; then
            ffmpeg -i "$video" -vcodec libx264 -crf 28 "$output"
        else
            echo "Skipping compression for $video, output file exists."
        fi
    else
        echo "Skipping non-video file: $video"
    fi
done

# Convert images to PNG with width 600px using ImageMagick
find "$DIRECTORY" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" \) | while IFS= read -r image; do
    output="${image%.*}_resized.png"
    if [ ! -f "$output" ]; then
        convert "$image" -resize 600x "$output"
    else
        echo "Skipping conversion for $image, output file exists."
    fi
done