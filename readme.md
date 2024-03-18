# Migrating from Google Photos to iCloud
A personal guide and some powershell scripts I used.

This guide outlines the process of migrating your photo library from Google Photos to iCloud using a series of PowerShell scripts, alongside other tools such as ExifTool, FFmpeg, and Google Photos EXIF tool. These scripts are designed for use with PowerShell version 7 or higher, leveraging parallel processing for efficiency.

## Requirements
- PowerShell version 7 or higher
- [ExifTool](https://exiftool.org/) for metadata manipulation
- [FFmpeg](https://ffmpeg.org/) for video format conversion
- [Google Photos EXIF Tool](https://github.com/mattwilson1024/google-photos-exif) for restoring original photo metadata from Google Takeout

## Step-by-Step Guide

### 1. Download Your Google Photos Library
Start by exporting your photo and video library from Google Photos using the Google Takeout service.

### 2. Restore Original Metadata
Utilize the Google Photos EXIF tool to restore metadata that was stripped during the Google Takeout process.

### 3. Correct Metadata Dates
Run the `1-correctDatesParallelA.ps1` script to harmonize date metadata across your files, ensuring that the 'created' and 'modified' date fields reflect the actual date the photo was taken.

### 4. Eliminate Duplicates
Use [Czkawka](https://github.com/qarmin/czkawka), a duplicate finder tool, to identify and compile a list of duplicate photos. This list should be saved to a text file (e.g., `2-filesToMove.txt`). This step helps in avoiding duplicates that may already exist in your local storage.

### 5. Execute the Move Script
With the list of duplicates prepared, run the `2-moveAlready.ps1` script to relocate listed files. This process helps in filtering out photos already present in your iPhone's local storage.

### 6. Convert Video Formats
To ensure compatibility with iOS, the `3-changeCodedMP4s.ps1` script converts non-H264/AAC videos to a compatible format using FFmpeg.

### 7. Transfer to iPhone
Finally, zip the processed photos and videos, and transfer them to your iPhone via AirDrop or Windows shared folders for fast transfer. Once on your iPhone, use the Files app to import the media into the Photos app. This method bypasses limitations associated with iTunes imports, offering a more flexible way to manage your photos in iOS.