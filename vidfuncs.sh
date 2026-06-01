#!/bin/bash

# Global variables

vid_conv() {
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo "Usage: vid_conv [input_video] [reference_image] [compression_level] "
        echo "Example: vid_conv ./input.mp4 ./reference.jpg 23"
        return 1
    fi

    local vid_in=$1         # input video
    local ref_img=$2        # reference image
    local comp_level=$3     # compression level (0-51, where 0 is lossless and 51 is worst quality)

    # 1. Strip the directory path (keep everything after the last /)
    local base=$(basename "$vid_in")

    # 2. Strip the extension (remove everything after the last .)
    local vid_out="${base%.*}.mp4"

     ffmpeg -i "$vid_in" -c:v libx265 -crf "$comp_level" -preset slow "$vid_out"

}