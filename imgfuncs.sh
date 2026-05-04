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


img_mv() { 
	local input=$1
	local output=$2
	local dryrun=$3   # set to false to actually move files
	
	# Validate input parameters
	if [ $# -ne 3 ]; then
	printf "Error: Function requires exactly 3 arguments (input folder, output folder, and dry-run true/false)
	Example: This command would create a dry-run for moving all jpeg images from ./input to ./ouput: 
	img_mv ./input ./ouput true "
	return 1
	fi

	# Collect all matching files
	mapfile -t files < <(
		find "$input" -type f -iregex ".*\.\(jpg\|jpeg\)"
	)

	total=${#files[@]}
	count=0

	for f in "${files[@]}"; do
		((count++))

		base=$(basename "$f")
		ext="${base##*.}"

		# Generate unique name with counter padded to 4 digits
		newname="$(printf "%s_%04d.%s" "${base%.*}" "$count" "$ext")"

		echo "Moving $count/$total: $f → $output/$newname"
		if [[ "$dryrun" == true ]]; then
		echo "[DRY‑RUN] Would move: $f → $output/$newname"
	else
		mv -f "$f" "$output/$newname"
	fi

	done
}