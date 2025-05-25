Read-Host "Press Enter to start processing files"

# Define the path to your TXT file containing the filenames
$txtFilePath = Read-Host "Enter the full path to the file listing duplicates"

# Define the source and destination directories
$sourceDirectory = Read-Host "Enter the source directory"
$destinationDirectory = Read-Host "Enter the destination directory"

# Define the path for the error log file
$logFilePath = Read-Host "Enter the log file path"

# Read the filenames from the TXT file
$fileNames = Get-Content $txtFilePath

# Ensure the destination directory exists
if (-not (Test-Path $destinationDirectory)) {
    Write-Host "Destination directory does not exist. Creating: $destinationDirectory"
    New-Item -ItemType Directory -Path $destinationDirectory
}

foreach ($fileName in $fileNames) {
    $sourceFilePath = Join-Path -Path $sourceDirectory -ChildPath $fileName
    $destinationFilePath = Join-Path -Path $destinationDirectory -ChildPath $fileName
    Write-Host "sourceFilePath $sourceFilePath"
    Write-Host "destinationFilePath $destinationFilePath"

    # Check if the file exists in the source directory
    if (Test-Path $sourceFilePath) {
        try {
            # Attempt to move the file
            Move-Item -Path $sourceFilePath -Destination $destinationFilePath -ErrorAction Stop
            Write-Host "File moved successfully: $fileName" -ForegroundColor DarkGreen
        } catch {
            # Handle errors (e.g., permission issues, file in use)
            $errorMessage = "Something went wrong moving the file: $fileName. Error: $_"
            Write-Host $errorMessage -ForegroundColor DarkRed
            $errorMessage | Out-File -FilePath $logFilePath -Append
        }
    } else {
        # File does not exist in the source directory
        $notFoundMessage = "File does not exist in the source directory: $fileName"
        Write-Host $notFoundMessage -ForegroundColor DarkRed
        $notFoundMessage | Out-File -FilePath $logFilePath -Append

    }
}

Write-Host "Processing complete."
Read-Host "Press Enter to finish"