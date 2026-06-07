#!/bin/bash

# Global variables
regex_ext='.*\.(jpg|jpeg)' # Cleaned up for posix-extended
std_ext='jpg' 

###########
# Image Functions
###########

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


#########
# Video Functions
#########

vid_conv() {
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo "Usage: vid_conv [input_video] [reference_image] [compression_level]"
        echo "Example: vid_conv ./input.avi ./reference.jpg 20"
        return 1
    fi

    local vid_in=$1         # input video
    local ref_img=$2        # reference image
    local comp_level=$3     # compression level (0-51, where 0 is lossless and 51 is worst quality)

    # Strip the directory path (keep everything after the last /)
    local base=$(basename "$ref_img")

    # Strip the extension (remove everything after the last .)
    local vid_converted="${vid_in%/*}/${base%.*}.mp4"

    # Convert the video using ffmpeg with the specified compression level and write to the same directory as the original video with the same name but .mp4 extension
    ffmpeg -i "$vid_in" -c:v libx265 -crf "$comp_level" -preset slow "$vid_converted"
    
    # Copy the GPS and creation date with time zone metadata from the reference image to the converted video using exiftool
    # exiftool -overwrite_original -tagsfromfile "$ref_img" -*date* -GPS*  "$vid_converted"

    # Copy GPS and creation date with UTC/Timezone handling using ExifTool
    exiftool -overwrite_original -api QuickTimeUTC=1 -tagsfromfile "$ref_img" \
        -Make -Model -*date* -Title -Keywords -GPS* \
        '-QuickTime:CreationDate<$DateTimeOriginal' \
        '-QuickTime:DateTimeOriginal<$DateTimeOriginal' \
        "$vid_converted"
}

vid_batch_conv() {
    # 1. Accept two directory paths as arguments, plus compression level
    local dir1="$1"
    local dir2="$2"
    local comp_level="$3" # compression level (0-51, where 0 is lossless and 51 is worst quality)

    # Validate that all arguments are provided and are actual directories
    if [[ -z "$dir1" || -z "$dir2" || -z "$comp_level" ]]; then
        echo "Error: Please provide two directory paths and a compression level." >&2
        echo "Usage: vid_conv [input_video_dir] [reference_image_dir] [compression_level]" >&2
        echo "Example: vid_conv ./input_vids/ ./reference_imgs/ 20" >&2
        return 1
    fi

    if [[ ! -d "$dir1" || ! -d "$dir2" ]]; then
        echo "Error: One or both provided paths are not valid directories." >&2
        return 1
    fi

    # Read filenames into array $files1 (ignoring directory paths, tracking only base names)
    local files1=()
    mapfile -t files1 < <(find "$dir1" -maxdepth 1 -type f -printf '%f\n')

    # 2. Read another directory of filenames into $files2
    local files2=()
    mapfile -t files2 < <(find "$dir2" -maxdepth 1 -type f -printf '%f\n')

    # Get the lengths of both arrays
    local len1=${#files1[@]}
    local len2=${#files2[@]}

    # 3. If length of $files1 != length of $files2, halt and print an error message
    if (( len1 != len2 )); then
        echo "Error: Directory file counts do not match!" >&2
        echo "  First directory has $len1 files." >&2
        echo "  Second directory has $len2 files." >&2
        return 1
    else
        # 4. Else, loop through the length and convert the videos in $files1 using the corresponding reference images in $files2, pairing them up by their index in the arrays
        for (( i=0; i<len1; i++ )); do
            echo "Video file:  ${files1[i]}  Reference file: ${files2[i]}"
            vid_conv "${dir1}/${files1[i]}" "${dir2}/${files2[i]}" "$comp_level"
        done
    fi
}