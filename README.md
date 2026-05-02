# Command Line Image Editing

Author: Michael Dear  
Date: May 2026

## Aim

This project uses command-line tools to complete operations on JPEG images such as renaming, adding keywords and titles to EXIF metadata, rotating, and resizing (scaling). Where possible, automation is achieved through custom command-line functions.

## Tools

* Git Bash
* ExifTool 
* ImageMagick

## Commands

The following commands are in the order of my usual workflow, but can be used independently or in any order. All commands are written for the Git Bash command line. 

## Write Title and Keywords to EXIF Metadata

The `img_group` function groups images into subdirectories by time. Each group is determined by a maximum time offset in minutes from the first image in the group.

Pseudocode

* offset = 10
* group = 1
* make the group_1 subdirectory
* get the directory's filename list
* get the first images's datetime
* move the first image to the group_1 directory
* while the current image's datetime is less than offset from the first image's datetime
 - move the current image to the group_1 directory
 - test the next file's datetime
* Add 1 to the group index: group = ++group
* Repeat the process until all images have been moved to a subdirectory

The `img_write_desc` function writes a title, description, and keywords to the EXIF metadata of an image file. 

## Rename Files Using EXIF Metadata

The `img_rename` function renames an image using EXIF metadata. The renaming pattern is *(camera model)-yyymmdd_hhmmss_(sequence number).jpg*. The *input* and *output* folders need to passed as arguments.

### Code

```
img_rename() {
    # $1 is the first folder (input)
    # $2 is the second folder (output)
    exiftool "-filename<$2/\${model;tr/ /_/;s/__+/_/g}-\${datetimeoriginal}" \
             -r -o . \
             -d "%Y%m%d_%H%M%S%%-c.%%le" "$1"
```

### Usage Example

This example will copy and rename all JPEG files in the `./original` folder using the renaming pattern and write them to the `./renamed` folder.

```
img_rename ./original ./renamed
```
 
### References

* [*Writing "FileName" and "Directory" tags*, ExifTool](https://exiftool.org/filename.html)
* [*exiftool rename photos with camera model and date*, StackOverflow](https://stackoverflow.com/a/28835675) 
* [*Exiftool: reorder images - copy them to folders based on their DateTimeOriginal [closed]*, StackOverflow](https://stackoverflow.com/a/75594683) for copy using `-o .`
* [*Filtering Only Image Files*, ExifTool Forum](https://exiftool.org/forum/index.php?msg=60709) for use of ext.args for filtering non-image files

## Group Files By Time



## General References

* [*Command Line Functions*, Code Academy](https://www.codecademy.com/resources/docs/command-line/bash/functions)
* [*The Unix Workbench: Chapter 5 Bash Programming*, Sean Kross](https://bookdown.org/sean/the-unix-workbench/bash-programming.html)


This document was compiled from markdown to html using [pandoc](https://pandoc.org/index.html) with styles provided by [Simple CSS](https://github.com/kevquirk/simple.css):

```
 pandoc -s -c simple.min.css README.md -o index.html
```