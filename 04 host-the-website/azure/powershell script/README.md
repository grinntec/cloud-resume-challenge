# Azure Static Website Deployment Script

This script is used to deploy a static website to Azure using PowerShell. 

## Variables

Here are the variables that need to be set before executing the script:

- `$appId`: The name of your application. (Example: "widget")
- `$subscriptionId`: The ID of your Azure subscription. (Example: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
- `$location`: The location of your Azure resources. (Example: "West US")
- `$pathToFiles`: The path to the website files you want to upload. (Example: "C:\Users\Username\Documents\Website")

## How it works

The script first sets up the required Azure resources, which include a Resource Group and a Storage Account. It then enables static website hosting on the Storage Account and uploads the website files to the `$web` container. Once the files are uploaded, the script fetches the primary endpoint for the static website and opens it in your default browser.

## Web content

This repository includes a `web-content` folder with three files; `index.html`, `script.js` and `style.css`. You can use these files as your web content or replace them with your own.

## How to use

1. Install the [Azure PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps) if it's not already installed.

2. Open PowerShell and navigate to the directory containing the script.

3. Set the variables mentioned above.

4. Run the script using the command `.\script.ps1`

Please note that you must have the appropriate permissions to create and manage resources in your Azure subscription. Also, the script assumes that you're using the 'Standard_RAGRS' redundancy option for the Storage Account, and that all HTML, CSS, and JS files in your local directory should be uploaded to the Storage Account. Make sure to modify these options as needed to suit your use case.

## Output

The script will output the primary endpoint for the static website, which is the URL where your website is hosted. You can share this URL with others to allow them to access your website.

If any part of the script fails, the script will stop execution and display a message indicating which part failed.

Please remember that this script may incur costs on your Azure subscription, depending on the resources that you create and use. Always monitor your usage and costs to avoid unexpected charges.