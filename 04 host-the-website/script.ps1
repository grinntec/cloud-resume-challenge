# Variables
$appId = "" # Example: "widget"
$subscriptionId = "" # Example: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
$location = ""  # Example: "West US"
$pathToFiles = ""  # Example: "C:\Users\Username\Documents\Website"

# Automated values based on variables
$resourceGroupName = "rg-" + $appId # Creating a name for the resource group
$storageAccountNamePrefix = $appId # Creating a prefix for the storage account name

# Function to generate a random string
function Get-RandomString($length = 8) {
    return -join ((65..90) + (97..122) | Get-Random -Count $length | % {[char]$_})
}

# Installing the Azure PowerShell module if not installed
if (!(Get-Module -ListAvailable -Name Az.Accounts)) {
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
}

# Import the module
Import-Module Az.Accounts

Write-Host "Logging in to Azure..."

# Login to your Azure account
Connect-AzAccount

if (-not $?) {
    Write-Host "Failed to log in to Azure. Stopping script."
    return
}

Write-Host "Setting subscription context..."

# Setting the subscription
Set-AzContext -SubscriptionId $subscriptionId

if (-not $?) {
    Write-Host "Failed to set Azure context. Stopping script."
    return
}

Write-Host "Creating resource group..."

# Creating the Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

if (-not $?) {
    Write-Host "Failed to create resource group. Stopping script."
    return
}

Write-Host "Creating storage account..."

# Creating the Storage Account with unique name
$storageAccountName = $storageAccountNamePrefix + (Get-RandomString -length 8).ToLower()
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_RAGRS -Kind StorageV2

if (-not $?) {
    Write-Host "Failed to create storage account. Stopping script."
    return
}

Write-Host "Waiting for storage account to be ready..."

# Check if the storage account is ready
do {
    Start-Sleep -Seconds 10
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue
} while ($null -eq $storageAccount)

Write-Host "Getting storage account key..."

# Getting the Storage Account Key
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[0]

if (-not $?) {
    Write-Host "Failed to get storage account key. Stopping script."
    return
}

Write-Host "Setting storage context..."

# Setting the Storage Context
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey

if (-not $?) {
    Write-Host "Failed to set storage context. Stopping script."
    return
}

# Enabling static website hosting
Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument index.html

if (-not $?) {
    Write-Host "Failed to enable static website on storage account. Stopping script."
    return
}

Write-Host "Uploading files to the web container..."

# Uploading files to the web container with conditional content type
Get-ChildItem -Path $pathToFiles -Recurse |
ForEach-Object {
    $blobName = $_.FullName.Substring($pathToFiles.Length + 1).Replace('\', '/')
    if ($_.Extension -eq ".html") {
        Set-AzStorageBlobContent -File $_.FullName -Blob $blobName -Container `$web -Context $ctx -Properties @{"ContentType" = "text/html"} -Force
    }
    if ($_.Extension -eq ".css") {
        Set-AzStorageBlobContent -File $_.FullName -Blob $blobName -Container `$web -Context $ctx -Properties @{"ContentType" = "text/css"} -Force
    }
    if ($_.Extension -eq ".js") {
        Set-AzStorageBlobContent -File $_.FullName -Blob $blobName -Container `$web -Context $ctx -Properties @{"ContentType" = "application/javascript"} -Force
    } 
}

if (-not $?) {
    Write-Host "Failed to upload files to the web container. Stopping script."
    return
}


# Get the primary static website endpoint
$primaryWebEndpoint = $storageAccount.PrimaryEndpoints.Web

Write-Host "The primary endpoint for the static website is: $primaryWebEndpoint"

# Wait for the web content to be loaded
Write-Host "Waiting for the web content to be ready..."
start-sleep -Seconds 15

# Open the primary endpoint in the default browser
Write-Host "Opening the site in the default browser"
Start-Process $primaryWebEndpoint

Write-Host "Script end"