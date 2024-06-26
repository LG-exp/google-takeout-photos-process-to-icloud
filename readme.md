# Migrating from Google Photos to iCloud on Windows
A personal guide and some powershell scripts I used.
Use at your own risk, I do not provide any guarantees. Hopefully this helps someone.

This guide outlines the process of migrating your photo library from Google Photos to iCloud using a series of PowerShell scripts on Windows 11, alongside other tools such as ExifTool, FFmpeg, and Google Photos Migrate EXIF Tool. These scripts are designed for use with PowerShell version 7 or higher, leveraging parallel processing for efficiency.

## Requirements
- PowerShell version 7 or higher
- [ExifTool](https://exiftool.org/) for metadata manipulation
- [FFmpeg](https://ffmpeg.org/) for video format conversion
- [Google Photos Migrate EXIF Tool](https://github.com/garzj/google-photos-migrate?tab=readme-ov-file) for restoring original photo metadata from Google Takeout

## Step-by-Step Guide

### 1. Download Your Google Photos Library
Start by exporting your photo and video library from Google Photos using the Google Takeout service. If Google gives you multiple Takeout folders merge all photos from an album (e.g. Photos from 2021) into a single folder.

### 2. Restore Original Metadata
Utilize the Google Photos Migrate EXIF Tool to restore metadata that was stripped during the Google Takeout process. You'll have to create an output and error folder.

### 3. Correct Metadata Dates
We'll use the `1-correctDatesParallelA.ps1` script to harmonize date metadata across your files, this script will read all media files in a folder, read each file metadata using ExifTool, it will extract all dates and select the oldest one to add/update all relevant metadata variables and modify the 'created' and 'modified' file/windows dates.

Beware this script tries to parse the metadata date as YYYY:MM:DD HH:MM:SS.

You should use this script in both your output folder as well as your error folder. Even though Google Photos Migrate EXIF Tool placed media in an error folder, all this means is that in most cases the media didn't have a JSON file associated. Still, some or most of these photos have a valid metadate, e.g. running ExifTool on one of those I can identify having a valid date under the variables Create Date, Date/Time Original and Modify Date (sometimes there are others).


### 4. Eliminate Duplicates (optional)
Use the [Czkawka](https://github.com/qarmin/czkawka) tool to identify duplicated images within the output and error folder.

Also, connect iPhone to Windows 11 via good cable for good transfer speeds, then open the Windows Photos App, and import all media from the iPhone. This way we can use [Czkawka](https://github.com/qarmin/czkawka) tool to identify which media in output/error are already in the iPhone local storage, and thus removing or moving out of the transfer this duplicated photos.

In my case I choose to non-destructive just move them out into another windows folder, for that purpose save the list of duplicates media filenames in a TXT file and name it: `2-filesToMove.txt`


### 4.1 Execute the Move Script (optional)
With the list of duplicates prepared, run the `2-moveAlready.ps1` script to relocate listed files into a new folder.

### 5. Convert Video Formats (optional)
To ensure compatibility with iOS, the `3-changeCodedMP4s.ps1` script converts non-H264/AAC videos to a compatible format using FFmpeg.

### 6. Transfer to iPhone
Finally, zip the processed photos and videos, and transfer them to your iPhone via AirDrop or Windows shared folders (SMB) for fast transfer. Once on your iPhone, use the Files app to import the media into the Photos app. This method bypasses limitations associated with iTunes/iCloud imports, offering a more flexible way to transfer the media into iOS. 

Tip: I imported in batches of 500 media at a single time as trying to do it all at once might result in the app crashing.

To-do: Try using MacOs Airdrop.

### 7. Wait for iOS to sync new photos to iCloud
That's it. Now just wait for iOS to sync over night all of the new photos imported the iPhone local storage.


## Further development
If at some point in my life I have time I'll develop a more robust solution in a better programming language (Go, Rust, Zig... or even Python).
