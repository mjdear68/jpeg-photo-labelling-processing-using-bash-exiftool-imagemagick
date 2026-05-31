#!/bin/bash

# Global variables
regex_ext='.*\.(jpg|jpeg)' # Cleaned up for posix-extended
std_ext='jpg' 

img_rename() {
    local input=$1    # input folder
    local output=$2   # output folder
    
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: img_rename [input_folder] [output_folder]"
        echo "Example: img_rename ./input ./output"
        return 1
    fi
    
    # Run the command
    find "$input" -regextype posix-extended -type f -iregex "$regex_ext" | \
        exiftool "-filename<$output/\${model;tr/ /_/;s/__+/_/g}-\${datetimeoriginal}" \
             -r -o . -d "%Y%m%d_%H%M%S%%-c.$std_ext" -@ -
}

img_group() {
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo "Usage: img_group_mins [input_folder] [output_folder] [interval_in_minutes] "
        echo "Example: img_group_mins ./input ./output 30"
        return 1
    fi

    local input=$1    # input folder
    local output=$2   # output folder
    local mins=$3     # minutes per interval

    find "$input" -regextype posix-extended -type f -iregex "$regex_ext" | \
    exiftool  '-Directory<$CreateDate/${CreateDate#;/(\d+):\d+$/;$_=sprintf("%02d",int($1/'"$mins"')*'"$mins"')}min' \
             -o . -d "$output/%Y-%m-%d_%H" \
             -if '$CreateDate' \
             -@ -
}

img_desc() {
    local input=$1      # input folder
    local title=$2    
    local keywords=$3   
    
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo "Usage: img_desc [input_folder] [title] [keywords] "
        echo 'Example: img_desc ./input "Autumn leaves" "landscape; trees;"'
        return 1
    fi
    
    # Run the command
    find "$input" -regextype posix-extended -type f -iregex "$regex_ext" | \
        exiftool -overwrite_original -Title="$title" -Keywords="$keywords" -@ -
}

img_gps_cp() {
    local ref=$1      # reference image
    local input=$2    # input folder

    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: img_gps_cp [reference_image] [input_folder]"
        echo 'Example: img_gps_cp ref.jpg ./input'
        return 1
    fi
    
    # Run the command
    find "$input" -regextype posix-extended -type f -iregex "$regex_ext" | \
        exiftool -overwrite_original -tagsfromfile "$ref" -GPSLatitude* -GPSLongitude* -GPSAltitude* -@ -
}

img_cp() {
    local input=$1
    local output=$2
    
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: img_cp [input_folder] [output_folder]"
        echo "Example: img_cp ./input ./output"
        return 1
    fi
    
    mkdir -p -v "$output"
    find "$input" -regextype posix-extended -type f -iregex "$regex_ext" -exec cp -v -r -i {} "$output/" \;
}

img_rm() {
    local input=$1
    
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ]; then
        echo "Usage: img_rm [input_folder]"
        echo "Example: img_rm ./input"
        echo "WARNING: This process cannot be undone."
        return 1
    fi
    
    # Get user confirmation
    read -p "WARNING: This process cannot be undone. Proceed? [y/N]: " choice
    
    case "$choice" in 
      [yY][eE][sS]|[yY]) 
        echo "Deleting image files and empty directories from '$input' ..."
        find "$input" -regextype posix-extended -type f -iregex "$regex_ext" -exec rm -v {} \;
        find "$input" -type d -empty -delete
        ;;
      *)
        echo "Operation aborted."
        return 0
        ;;
    esac
}

img_resize() {
    local input=$1
    local output=$2
    local new_width=$3
    
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo "Usage: img_resize [input_folder] [output_folder] [new_width_px_or_%] "
        echo "Example: img_resize ./input ./output 50%"
        return 1
    fi
        
    mkdir -p -v "$output"
    find "$input" -regextype posix-extended -type f -iregex "$regex_ext" -exec magick mogrify -path "$output" -resize "$new_width" {} +
}

img_rotate() {
    local input=$1
    local output=$2
    local angle=$3
    
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo "Usage: img_rotate [input_folder] [output_folder] [angle_degrees] "
        echo "Example: img_rotate ./input ./output 90"
        return 1
    fi
        
    mkdir -p -v "$output"
    find "$input" -regextype posix-extended -type f -iregex "$regex_ext" -exec magick mogrify -path "$output" -rotate "$angle" {} +
}