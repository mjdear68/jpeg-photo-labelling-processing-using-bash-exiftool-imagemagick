#!/bin/bash

# Global variables
regex_ext='.*\.\(jpg\|jpeg\)' # regular expression for `find`
# etool_ext='$filename=~/.jpg|jpeg/i' # for exiftool commands
std_ext='jpg' # standard extension for renamed files

img_rename() {
	local input=$1    # input folder
    local output=$2   # output folder

	# Validate input parameters
	if [ $# -ne 2 ]; then
		echo "Function requires exactly 2 arguments (input folder and output folder)"
		echo "Example: This command will rename all jpeg images using the format camera-make_yyyymmdd_hhmmss. A sequential number will be added to the end of filename collisions. Files are copied to the output directory."
		echo "img_rename input output"
	return 1
	fi
	
	# Run the command
    # exiftool -if $etool_ext \
	find "$input" -type f -iregex $regex_ext | \
			exiftool "-filename<$output/\${model;tr/ /_/;s/__+/_/g}-\${datetimeoriginal}" \
             -r -o . -d "%Y%m%d_%H%M%S%%-c.$std_ext" -@ -
             #-d "%Y%m%d_%H%M%S%%-c.$std_ext" "$input"
}


img_group() {

	local input=$1    # input folder
	local output=$2   # output folder

	# Validate input parameters
	if [ $# -ne 2 ]; then
		echo "Function requires exactly 2 arguments (input folder and output folder)"
		echo "Example: This command will copy the jpeg images from the input directory into subdirectories of the output directory grouped by create date and hour."
		echo "img_group input output"
	return 1
	fi
	
	# Run the command
    # exiftool -if $etool_ext "-Directory<CreateDate" \
	find "$input" -type f -iregex $regex_ext | \
			exiftool "-Directory<CreateDate" \
             -r -o . -d "$output/%Y-%m-%d_%H00" -@ -
			# -d "$output/%Y-%m-%d_%H00" "$input"
			 
             
}

img_write_desc() {
	local input=$1 		# input folder
	local title=$2    
	local keywords=$3 	

	# Validate input parameters
	if [ $# -ne 3 ]; then
		echo "Function requires exactly 3 arguments (input folder, title, and keywords)"
		echo "Example: This command will write a title and keywords to all jpeg images in the input directory. Keywords should be separated by semi-colons for MS Windows."
		echo 'img_write_desc ./input "Autumn leaves in a suburban street" "landscape; trees; autumn" '
	return 1
	fi
	
	# Run the command
    # exiftool -if $etool_ext -overwrite_original \
	find "$input" -type f -iregex $regex_ext | \
		exiftool -overwrite_original -Title="$title" -Keywords="$keywords" -@ -
		# -Title="$title" -Keywords="$keywords" "$input"
             
}


img_cp() {
	
	local input=$1
	local output=$2
	
	# Validate input parameters
	if [ $# -ne 2 ]; then
		echo "Function requires exactly 2 arguments (input folder, output folder)"
		echo "Example: This command would copy all jpeg images from ./input to ./ouput:" 
		echo "img_cp input ouput"
	return 1
	fi
	
	mkdir -p -v "$output"
	
	find "$input" -type f -iregex $regex_ext -exec cp -v -r -i {} "$output/" \;
}


img_rm() {

	local input=$1
	
	# Validate input parameters
	if [ $# -ne 1 ]; then
		echo "Function requires exactly 1 argument (folder to delete).
		Images will be deleted recursively."
		echo "Example: This command would delete all jpeg images and empty directories recursively from ./input:"
		echo "img_rm input"
	return 1
	fi
	
	find "$input" -type f -iregex $regex_ext -exec rm -v {} \;
	
	find "$input" -type d -empty -delete
}

img_resize() {
	
	local input=$1
	local output=$2
	local new_width=$3
	
	# Validate input parameters
	if [ $# -ne 3 ]; then
		echo "Function requires exactly 3 arguments (input directory or filename, output directory, and new width as px or percent)."
		echo "Example: This command would resize all jpeg images in ./input to 50% of their original width:"
		echo "img_resize input output 50%"
	return 1
	fi
		
	mkdir -p -v "$output"
	
	find "$input" -type f -iregex $regex_ext -exec magick mogrify -path "$2" -resize "$3" "$1" \;
}


img_rotate() {
	
	local input=$1
	local output=$2
	local new_width=$3
	
	# Validate input parameters
	if [ $# -ne 3 ]; then
		echo "Function requires exactly 3 arguments (input directory or filename, output directory, and the rotation angle in degrees)."
		echo "Example: This command would rotate all jpeg images in ./input 90 degrees clockwise:"
		echo "img_resize input output 90"
	return 1
	fi
		
	mkdir -p -v "$output"
	
	find "$input" -type f -iregex $regex_ext -exec magick mogrify -path "$2" -rotate "$3" "$1" \;
}