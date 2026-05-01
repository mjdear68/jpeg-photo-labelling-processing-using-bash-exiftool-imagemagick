# Command Line Image Editing

## Aim
This project uses command-line tools to complete operations on JPEG images such as renaming, adding keywords and titles to EXIF metadata, rotating, and resizing (scaling). Where possible, automation is achieved through custom command-line functions.

## Tools
* Git Bash
* ExifTool 
* ImageMagick

## Commands
The following commands are grouped by intended use. All commands are written for the Git Bash command line. 

### Rename Files Using EXIF metadata

This function renames an image using EXIF metadata. The renaming pattern is *(camera model)-yyymmdd_hhmmss_(sequence number).jpg*. The *input* and *output* folders need to passed as parameters.

**Code**
```
img_rename() {
    # $1 is the first folder (input)
    # $2 is the second folder (output)
    exiftool "-filename<$2/\${model;tr/ /_/;s/__+/_/g}-\${datetimeoriginal}" \
             -r -o . \
             -d "%Y%m%d_%H%M%S%%-c.%%le" "$1"
```

**Usage Example**
This example will copy and rename all JPEG files in the `./original/` folder using the renaming pattern and write them to the `./renamed/` folder.

`img_rename ./original/ ./renamed/`
 
**References**
* https://exiftool.org/filename.html
* https://stackoverflow.com/a/28835675 for camera model and datetime format
* https://stackoverflow.com/a/75594683 for copy using `-o .`
* function code logic by Google Gemini


## General References
[*Command Line Functions*, Code Academy](https://www.codecademy.com/resources/docs/command-line/bash/functions)