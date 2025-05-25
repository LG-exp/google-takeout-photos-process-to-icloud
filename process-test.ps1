# PowerShell script to test metadata correction on a single file
param(
    [string]$Path
)

if (-not $Path) {
    $Path = Read-Host "Enter path to a file or directory"
}

if (-not (Test-Path $Path)) {
    Write-Host "Path not found: $Path" -ForegroundColor Red
    exit 1
}

$targetItem = Get-Item $Path
if ($targetItem.PSIsContainer) {
    $file = Get-ChildItem $targetItem.FullName -File | Select-Object -First 1
    if (-not $file) {
        Write-Host "No files found in directory: $Path" -ForegroundColor Red
        exit 1
    }
} else {
    $file = $targetItem
}

$exiftool = "exiftool"
$culture = [Globalization.CultureInfo]::InvariantCulture
$formats = @('yyyy:MM:dd HH:mm:ss', 'yyyy:MM:dd HH:mm:sszzz', 'yyyy:MM:dd HH:mm:ss.fffZ')

Write-Host "Processing file: $($file.FullName)" -ForegroundColor Cyan
Write-Host "Metadata before:" -ForegroundColor Yellow
& $exiftool -DateTimeOriginal -TrackCreateDate -TrackModifyDate -MediaCreateDate -MediaModifyDate -MetadataDate -FileModifyDate -CreateDate -ModifyDate -s $file.FullName

$metadataOutput = & $exiftool -DateTimeOriginal -TrackCreateDate -TrackModifyDate -MediaCreateDate -MediaModifyDate -MetadataDate -s3 -d "%Y:%m:%d %H:%M:%S" $file.FullName

$dateList = @()
foreach ($line in $metadataOutput) {
    if ($line -match "\d{4}:\d{2}:\d{2} \d{2}:\d{2}:\d{2}") {
        foreach ($format in $formats) {
            try {
                $dateList += [datetime]::ParseExact($line, $format, $culture)
                break
            } catch {}
        }
    }
}
$correctDate = $dateList | Sort-Object | Select-Object -First 1

if ($correctDate) {
    $dateString = $correctDate.ToString('yyyy:MM:dd HH:mm:ss')
    $dateStringNoTime = $correctDate.ToString('yyyy:MM:dd')
    & $exiftool -q -q "-FileModifyDate=${dateString}-07:00" "-FileAccessDate=${dateString}-07:00" "-FileCreationDate=${dateString}-07:00" "-CreateDate=${dateString}" "-ModifyDate=${dateString}" "-GPSDateTime=${dateString}Z" "-GPSDateStamp=${dateStringNoTime}" "-overwrite_original_in_place" $file.FullName
    $file.LastWriteTime = $correctDate
    $file.CreationTime = $correctDate
} else {
    Write-Host "No valid date found." -ForegroundColor Red
}

Write-Host "Metadata after:" -ForegroundColor Yellow
& $exiftool -DateTimeOriginal -TrackCreateDate -TrackModifyDate -MediaCreateDate -MediaModifyDate -MetadataDate -FileModifyDate -CreateDate -ModifyDate -s $file.FullName
