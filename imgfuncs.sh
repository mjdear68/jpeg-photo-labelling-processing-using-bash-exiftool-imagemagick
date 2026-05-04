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
	local title=$1    
	local keywords=$2 	
	local input=$3 		# input folder

	# Validate input parameters
	if [ $# -ne 3 ]; then
	echo 'Error: Function requires exactly 3 arguments (title, keywords, and input folder)\n
	Example: "Autumn leaves in a suburban street" "landscape; trees; autumn" ./input'
	return 1
	fi
	
	# Run the command
    exiftool -@ ext.args -overwrite_original -Title="$title" -Keywords="$keywords" "$input"
             
}
