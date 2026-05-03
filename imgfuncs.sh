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
			 -d "$output%Y-%m-%d-_%H00" "$input"
             
}