# Wait for the user to press Enter to start
Read-Host "Press Enter to start processing files"

# Define the target directory
$targetDirectory = "C:\Users\Daniel Bañuelos\Desktop\takeout-20240305T230527Z-001\3gps"

# Get all files in the directory
$files = Get-ChildItem $targetDirectory -File

# Throttle limit can be adjusted based on your system's capabilities
$throttleLimit = 12

$files | ForEach-Object -Parallel {
    $file = $_
    $exiftoolPath = "exiftool" # Make sure exiftool is accessible in your PATH or specify its full path
    $culture = [Globalization.CultureInfo]::InvariantCulture
    $formats = @('yyyy:MM:dd HH:mm:ss', 'yyyy:MM:dd HH:mm:sszzz', 'yyyy:MM:dd HH:mm:ss.fffZ')

    # Fetching relevant dates with a single ExifTool call
    $metadataOutput = & $exiftoolPath -DateTimeOriginal -TrackCreateDate -TrackModifyDate -MediaCreateDate -MediaModifyDate -MetadataDate -s3 -d "%Y:%m:%d %H:%M:%S" $file.FullName

    # Parsing the output to find the earliest date
    $dateList = @()
    foreach ($line in $metadataOutput) {
        if ($line -match "\d{4}:\d{2}:\d{2} \d{2}:\d{2}:\d{2}") {
            try {
                $parsedDate = [datetime]::ParseExact($line, "yyyy:MM:dd HH:mm:ss", $culture)
                $dateList += $parsedDate
            } catch {}
        }
    }
    $correctDate = $dateList | Sort-Object | Select-Object -First 1

    if ($correctDate) {

        $dateStringWithoutMilliseconds = $correctDate.ToString("yyyy:MM:dd HH:mm:ss")
        $dateStringWithMilliseconds = $correctDate.ToString("yyyy:MM:dd HH:mm:ss.fff")
        $dateStringNoTime = $correctDate.ToString("yyyy:MM:dd")
        & $exiftoolPath -q -q "-FileModifyDate=${dateStringWithoutMilliseconds}-07:00" "-FileAccessDate=${dateStringWithoutMilliseconds}-07:00" "-FileCreationDate=${dateStringWithoutMilliseconds}-07:00" "-CreateDate=${dateStringWithoutMilliseconds}" "-ModifyDate=${dateStringWithoutMilliseconds}" "-GPSDateTime=${dateStringWithoutMilliseconds}Z" "-GPSDateStamp=${dateStringNoTime}" "-overwrite_original_in_place" $file.FullName

        # Update the file's LastWriteTime and CreationTime
        $file.LastWriteTime = $correctDate
        $file.CreationTime = $correctDate


        Write-Host "F: $($file.Name) `n CD: $dateStringWithoutMilliseconds `n" -ForegroundColor DarkGreen
    } else {
        Write-Host "ERROR NO VALID DATE FOUND FOR FILE: $($file.Name) `n`n" -ForegroundColor DarkRed
    }
} -ThrottleLimit $throttleLimit

Write-Host "Processing complete. Press Enter to exit." -ForegroundColor DarkGreen
Read-Host "Press Enter to exit"