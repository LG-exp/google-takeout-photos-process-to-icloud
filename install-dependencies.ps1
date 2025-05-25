# Checks for PowerShell 7, ExifTool, FFmpeg, and Google Photos Migrate EXIF Tool.
# Installs missing dependencies using winget or choco when available.

function Test-Command {
    param([string]$Name)
    return Get-Command $Name -ErrorAction SilentlyContinue
}

function Install-Package {
    param(
        [string]$WingetId,
        [string]$ChocoId
    )
    if (Test-Command 'winget') {
        winget install --id $WingetId -e
    } elseif (Test-Command 'choco') {
        choco install $ChocoId -y
    } else {
        Write-Host "Neither winget nor choco is available. Please install $WingetId manually."
    }
}

# PowerShell 7 check
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host 'PowerShell 7 is required.'
    Install-Package 'Microsoft.PowerShell' 'powershell'
} else {
    Write-Host 'PowerShell 7 is already installed.'
}

# ExifTool check
if (-not (Test-Command 'exiftool')) {
    Write-Host 'ExifTool not found. Installing...'
    Install-Package 'PhilHarvey.ExifTool' 'exiftool'
} else {
    Write-Host 'ExifTool is already installed.'
}

# FFmpeg check
if (-not (Test-Command 'ffmpeg')) {
    Write-Host 'FFmpeg not found. Installing...'
    Install-Package 'Gyan.FFmpeg' 'ffmpeg'
} else {
    Write-Host 'FFmpeg is already installed.'
}

# Google Photos Migrate EXIF Tool check
$gphotosTool = Test-Command 'google-photos-migrate-exif-tool'
if (-not $gphotosTool -and -not (Get-ChildItem -Path . -Filter 'google-photos-migrate-exif-tool*.jar' -ErrorAction SilentlyContinue)) {
    Write-Host 'Google Photos Migrate EXIF Tool not found. Installing...'
    Install-Package 'garzj.GooglePhotosMigrateExifTool' 'google-photos-migrate-exif-tool'
} else {
    Write-Host 'Google Photos Migrate EXIF Tool is already installed.'
}
