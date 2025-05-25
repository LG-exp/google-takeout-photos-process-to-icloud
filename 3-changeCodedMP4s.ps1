# Define the source and destination directories
$sourceDirectory = Read-Host "Enter the source directory"
$destinationDirectory = Read-Host "Enter the destination directory"

# Get all MP4 files from the source directory
$mp4Files = Get-ChildItem $sourceDirectory -Filter *.3gp

$mp4Files | ForEach-Object -Parallel {
    $inputFile = $_.FullName
    $outputFile = Join-Path -Path $using:destinationDirectory -ChildPath ($_.BaseName + "-processed.mp4")

    Write-Host "input file: $inputFile"
    Write-Host "output file: $outputFile"

    $ffmpegCommand = "ffmpeg -i `"$inputFile`" -vcodec libx264 -acodec aac -map_metadata 0 `"$outputFile`""

    Invoke-Expression $ffmpegCommand

    Write-Host "Processed file saved to: $outputFile"
} -ThrottleLimit 6


Write-Host "Processing complete."