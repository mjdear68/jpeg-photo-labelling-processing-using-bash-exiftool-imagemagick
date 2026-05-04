#!/bin/bash

img_rename() {
	local input=$1    # input folder
    local output=$2   # output folder

	# Validate input parameters
	if [ $# -ne 2 ]; then
	echo "Error: Function requires exactly 2 arguments (input folder and output folder)"
	return 1
	fi
	
	# Run the command
    exiftool -@ ext.args "-filename<$output/\${model;tr/ /_/;s/__+/_/g}-\${datetimeoriginal}" \
             -r -o . \
             -d "%Y%m%d_%H%M%S%%-c.%%le" "$input"
}


img_group() {
	local input=$1    # input folder
	local output=$2   # output folder

	# Validate input parameters
	if [ $# -ne 2 ]; then
	echo "Error: Function requires exactly 2 arguments (input folder and output folder)"
	return 1
	fi
	
	# Run the command
    exiftool -@ ext.args "-Directory<CreateDate" \
             -r -o . \
			 -d "$output/%Y-%m-%d_%H00" "$input"
             
}

img_write_desc() {
	local input=$1 		# input folder
	local title=$2    
	local keywords=$3 	

	# Validate input parameters
	if [ $# -ne 3 ]; then
	printf 'Error: Function requires exactly 3 arguments (input folder, title, and keywords)
	Example: img_write_desc ./input "Autumn leaves in a suburban street" "landscape; trees; autumn" '
	return 1
	fi
	
	# Run the command
    exiftool -@ ext.args -overwrite_original -Title="$title" -Keywords="$keywords" "$input"
             
}


img_cp() {
	
	local input=$1
	local output=$2
	
	# Validate input parameters
	if [ $# -ne 2 ]; then
	printf "Error: Function requires exactly 2 arguments (input folder, output folder)
	Example: This command would copy all jpeg images from ./input to ./ouput: 
	img_cp input ouput"
	return 1
	fi
	
	# Make output directory if it doesn't exist
	# https://stackoverflow.com/a/59839/8299958
	# if [ ! -d "$output" ]; then
	  # mkdir "$output"
	# fi
	
	mkdir -p -v "$output"
	
	find "$input" -type f -iregex ".*\.\(jpg\|jpeg\)" -exec cp -v -r -i {} "$output/" \;
}


img_rm() {

	local input=$1
	
	# Validate input parameters
	if [ $# -ne 1 ]; then
	printf "Error: Function requires exactly 1 argument (folder to delete).
	Images will be deleted recursively.
	Example: This command would delete all jpeg images recursively from ./input: 
	img_rm input"
	return 1
	fi
	
	find "$input" -type f -iregex ".*\.\(jpg\|jpeg\)" -exec rm -v {} \;
	
	find "$input" -type d -empty -delete
}