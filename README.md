# Command Line Image Editing

Author: Michael Dear  
Date: May 2026

## About

This project uses *ExifTool* and *ImageMagick* commands to process JPEG photographic images. 
The imgfuncs.sh file contains *Bash* functions for renaming files with metadata, writing 
keywords and titles to metadata, and rotating and resizing images. The functions work on a 
directory or individual-file level.

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

| Tool | Use |
|------|---------|
| [Git Bash (5.2.26(1)-release x86_64-pc-msys)](https://git-scm.com/) | Shell: executing the functions in imgfuncs.sh; copying and deleting files  |
| [ExifTool (13.45)](https://exiftool.org/)  | Accessing image metadata: reading, writing, and file renaming. |
| [ImageMagick (7.1.2-17 Q16-HDRI x64)](https://imagemagick.org/) | Image manipulation: resizing and rotating. |

: Tools Summary Table


## Workflow 

Although the functions can be used independently, they are best used as a part of an image processing workflow. My typical workflow follows the steps in the Image Processing Workflow table.

| Step | Command |
|------|---------|
| Load `imgfuncs.sh` | `source imgfuncs.sh` (assuming `imgfuncs.sh` is in the current directory) |
| Make temporary directories | `mkdir photos photos/original` |
| Change to the `photos` directory | `cd photos` |
| Camera dump into `original` directory | Drag-and-drop or your preferred method |
| Rename images | `img_rename original renamed` |
| Group images | `img_group renamed grouped` |
| Manual review, then write title and keywords | `img_write_desc group_dir "Image title" "kwd1; kwd2; kwd3"` |
| Copy to image archive | `img_cp grouped archive_dir` |
| Clean up | `img_rm .` |

: Image Processing Workflow

Resizing and rotating images is not a part of my regular workflow. I usually complete these operations as the need arises by copying the relevant files to a separate directory after the main processing workflow.