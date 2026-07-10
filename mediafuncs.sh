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

img_exif_to_csv() {
	local input="$1"
	local output_csv="$2"
	
    # Safety Check: Ensure all arguments are provided
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: img_exif_to_csv [input_folder] [output_file.csv]"
		echo "Example: img_exif_to_csv ./input metadata.csv" 
        return 1
    fi

    # Verify the target directory actually exists
    if [ ! -d "$input" ]; then
        echo "Error: Directory '$input' does not exist."
        return 1
    fi

    echo "Extracting metadata from '$input' into '$output_csv'..."
	
	# Run the command
	# -n -c "%.6f" gives signed decimal coords
    find "$input" -regextype posix-extended -type f -iregex "$regex_ext" | \
        exiftool -csv -r \
		-Title -Subject -Keywords \
		-GPSLatitude* -GPSLongitude* -GPSAltitude* \
		-n -c "%.6f" \
		-@ - > "$output_csv"

    if [ $? -eq 0 ]; then
        echo "Success! Metadata exported to $output_csv"
    else
        echo "An error occurred during extraction."
        return 1
    fi
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
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
        echo "Usage: vid_conv [input_video] [reference_image] [output_dir] [compression_level]"
        echo "Example: vid_conv ./input.avi ./reference.jpg ./output 20"
        return 1
    fi

    local vid_in=$1         # input video
    local ref_img=$2        # reference image
    local output_dir=$3     # output directory
    local comp_level=$4     # compression level (0-51, where 0 is lossless and 51 is worst quality)

    # Strip the directory path (keep everything after the last /)
    local base=$(basename "$ref_img")

    # Strip the extension (remove everything after the last .)
    local vid_converted="${output_dir}/${base%.*}.mp4"

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
    # 1. Accept video directory,  paths as arguments, plus compression level
    local vid_dir="$1"
    local ref_dir="$2"
    local output_dir="$3"
    local comp_level="$4" # compression level (0-51, where 0 is lossless and 51 is worst quality)

    # Validate that all arguments are provided and are actual directories
    if [[ -z "$vid_dir" || -z "$ref_dir" || -z "$output_dir" || -z "$comp_level" ]]; then
        echo "Usage: vid_batch_conv [input_video_dir] [reference_image_dir] [output_dir] [compression_level]" >&2
        echo "Example: vid_batch_conv ./input_vids/ ./reference_imgs/ ./output 20" >&2
        return 1
    fi

    if [[ ! -d "$vid_dir" || ! -d "$ref_dir" ]]; then
        echo "Error: One or both provided paths are not valid directories." >&2
        return 1
    fi

    # Read filenames into array $vid_files (ignoring directory paths, tracking only base names)
    local vid_files=()
    mapfile -t vid_files < <(find "$vid_dir" -maxdepth 1 -type f -printf '%f\n')

    # 2. Read another directory of filenames into $ref_files
    local ref_files=()
    mapfile -t ref_files < <(find "$ref_dir" -maxdepth 1 -type f -printf '%f\n')

    # Get the lengths of both arrays
    local len1=${#vid_files[@]}
    local len2=${#ref_files[@]}

    # 3. If length of $vid_files != length of $ref_files, halt and print an error message
    if (( len1 != len2 )); then
        echo "Error: Directory file counts do not match!" >&2
        echo "  First directory has $len1 files." >&2
        echo "  Second directory has $len2 files." >&2
        return 1
    else
        # 4. Else, loop through the length and convert the videos in $vid_files using the corresponding reference images in $ref_files, pairing them up by their index in the arrays
        for (( i=0; i<len1; i++ )); do
            echo "Video file:  ${vid_files[i]}  Reference file: ${ref_files[i]}"
            vid_conv "${vid_dir}/${vid_files[i]}" "${ref_dir}/${ref_files[i]}" "$output_dir" "$comp_level"
        done
    fi
}