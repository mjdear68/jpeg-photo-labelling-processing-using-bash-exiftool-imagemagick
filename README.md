# Command Line Image Editing

Author: Michael Dear  
Date: May 2026

## About

This project uses command-line tools to process JPEG images. The imgfuncs.sh file contains bash functions for renaming, adding keywords and titles to metadata, rotating, and resizing jpeg images. The functions work on a directory or individual file level.

## Functions

The Functions Summary Table lists the functions and their purpose. Calling a function without parameters will print a description of the function and a usage example.


| Name | Purpose |
|------|---------|
| img_rename | Rename images using image metadata. Format *(camera model)-yyymmdd_hhmmss_(sequence number).jpg* |
| img_group | Copies jpeg images from the input directory into subdirectories of the output directory grouped by create date and hour e.g. 2026-05-05_1700 |
| img_write_desc | Writes a title and keywords to all jpeg images in the input directory. |
| img_cp | Copy all jpeg images from the input directory to the ouput directory. |
| img_rm | Delete all jpeg images and empty directories recursively from the input directory.|
| img_resize | Resizes all jpeg images in the input directory to a given pixel width or percentage of original size. Writes resized images to the output directory. |
| img_rotate | Rotates all jpeg images in the input directory n degrees clockwise. Writes rotated images to the output directory. |

: Functions Summary Table  


## Tools

* Git Bash
* ExifTool 
* ImageMagick

## Commands

The following commands are in the order of my usual workflow, but can be used independently or in any order. All commands are written for the Git Bash command line. 

## Rename Files Using Image Metadata

The `img_rename` function renames an image using image metadata. The renaming pattern is *(camera model)-yyymmdd_hhmmss_(sequence number).jpg*. The *input* and *output* folders need to passed as arguments.

### Code

```
img_rename() {
    # $1 is the first folder (input)
    # $2 is the second folder (output)
    Imagetool "-filename<$2/\${model;tr/ /_/;s/__+/_/g}-\${datetimeoriginal}" \
             -r -o . \
             -d "%Y%m%d_%H%M%S%%-c.%%le" "$1"
```

### Usage Example

This example will copy and rename all JPEG files in the `./original` folder using the renaming pattern and write them to the `./renamed` folder.

```
img_rename ./original ./renamed
```
 
### References

* [*Writing "FileName" and "Directory" tags*, ImageTool](https://Imagetool.org/filename.html)
* [*Imagetool rename photos with camera model and date*, StackOverflow](https://stackoverflow.com/a/28835675) 
* [*Imagetool: reorder images - copy them to folders based on their DateTimeOriginal [closed]*, StackOverflow](https://stackoverflow.com/a/75594683) for copy using `-o .`
* [*Filtering Only Image Files*, ImageTool Forum](https://Imagetool.org/forum/index.php?msg=60709) for use of ext.args for filtering non-image files


## Group Files By Date and Hour 

The `img_group` function groups images into subdirectories by creation date and hour e.g. "2026-04-27_0900".

### Code
```
img_group() {
	local input=$1    # input folder
	local output=$2   # output folder

	# Validate input parameters
	if [ $# -ne 2 ]; then
	echo "Error: Function requires exactly 2 arguments (input folder and output folder)"
	return 1
	fi
	
	# Run the command
    Imagetool -@ ext.args "-Directory<CreateDate" \
             -r -o . \
			 -d "$output%Y-%m-%d-_%H00" "$input"
             
}
```

## Write Title, Description, and Keywords to Image Metadata

The `img_write_desc` function writes a title, description, and keywords to the image metadata of an image file.


## Move Image Files
Logic based on https://copilot.microsoft.com/shares/vJThSveM3bEtbJ5kU1fFN

## General References

* [*Command Line Functions*, Code Academy](https://www.codecademy.com/resources/docs/command-line/bash/functions)
* [*The Unix Workbench: Chapter 5 Bash Programming*, Sean Kross](https://bookdown.org/sean/the-unix-workbench/bash-programming.html)

https://Imagetool.org/filename.html#ex6
https://github.com/jonkeren/Exiftool-Commands

This document was compiled from markdown to html using [pandoc](https://pandoc.org/index.html) with styles provided by [Simple CSS](https://github.com/kevquirk/simple.css):

```
 pandoc -s -c simple.css README.md -o index.html
```