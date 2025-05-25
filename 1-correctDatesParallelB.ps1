# Wait for the user to press Enter to start
Read-Host "Press Enter to start processing files"

# Define the target directory
$targetDirectory = "C:\Users\Daniel Bañuelos\Desktop\takeout-20240305T230527Z-001\outputmp4s"

# Get all files in the directory
$files = Get-ChildItem $targetDirectory -File

# Throttle limit can be adjusted based on your system's capabilities
$throttleLimit = 12

$files | ForEach-Object -Parallel {
    $file = $_
    $exiftoolPath = "exiftool" # Make sure exiftool is accessible in your PATH or specify its full path
    $dateTimeOriginal = & $exiftoolPath -DateTimeOriginal -s3 $file.FullName
    $correctDate = $null
    $formats = @('yyyy:MM:dd HH:mm:ss', 'yyyy:MM:dd HH:mm:sszzz', 'yyyy:MM:dd HH:mm:ss.fffZ')
    $culture = [Globalization.CultureInfo]::InvariantCulture

    foreach ($format in $formats) {
        try {
            $correctDate = [datetime]::ParseExact($dateTimeOriginal.Trim(), $format, $culture)
            break
        } catch {
            continue
        }
    }
    
    if (-not $correctDate) {
        $metadataDate = & $exiftoolPath -MetadataDate -s3 $file.FullName
        foreach ($format in $formats) {
            try {
                $correctDate = [datetime]::ParseExact($metadataDate.Trim(), $format, $culture)
                break
            } catch {
                continue
            }
        }
    }

    if ($correctDate) {

        $dateStringWithoutMilliseconds = $correctDate.ToString("yyyy:MM:dd HH:mm:ss")
        $dateStringWithMilliseconds = $correctDate.ToString("yyyy:MM:dd HH:mm:ss.fff")
        $dateStringNoTime = $correctDate.ToString("yyyy:MM:dd")
        & $exiftoolPath -q -q "-FileModifyDate=${dateStringWithoutMilliseconds}-07:00" "-FileAccessDate=${dateStringWithoutMilliseconds}-07:00" "-FileCreationDate=${dateStringWithoutMilliseconds}-07:00" "-CreateDate=${dateStringWithoutMilliseconds}" "-ModifyDate=${dateStringWithoutMilliseconds}" "-GPSDateTime=${dateStringWithoutMilliseconds}Z" "-GPSDateStamp=${dateStringNoTime}" $file.FullName

        Write-Host "F: $($file.Name) `n CD: $dateStringWithoutMilliseconds `n DTO: $dateTimeOriginal `n`n" -ForegroundColor DarkGreen
    } else {
        Write-Host "ERROR NO VALID DATE FOUND FOR FILE: $($file.Name) `n`n" -ForegroundColor DarkRed
    }
} -ThrottleLimit $throttleLimit

Write-Host "Processing complete. Press Enter to exit." -ForegroundColor DarkGreen
Read-Host "Press Enter to exit"