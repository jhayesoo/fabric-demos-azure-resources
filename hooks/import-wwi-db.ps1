$keyVaultName = azd env get-value AZURE_KEYVAULT_NAME
$rg = azd env get-value AZURE_RESOURCE_GROUP_NAME
$serverName = azd env get-value AZURE_SQL_SERVER_NAME
$sqlAdminUser = azd env get-value AZURE_SQL_SERVER_ADMIN_LOGIN
$storageAccountName = azd env get-value AZURE_STORAGE_ACCOUNT_NAME

$fileName = "WideWorldImporters-Standard.bacpac"
$wwiBacpacUri = "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Standard.bacpac"
$storageURI = "https://$storageAccountName.blob.core.windows.net/bacpacs/$fileName"

# Define the path to the .bacpacs directory relative to the script's location
$bacpacsDir = Join-Path -Path $PSScriptRoot -ChildPath "../.bacpacs"

# Create the .bacpacs directory if it doesn't exist
if (-not (Test-Path -Path $bacpacsDir)) {
    New-Item -ItemType Directory -Path $bacpacsDir
}

# Define the full path to the output file
$outputFilePath = Join-Path -Path $bacpacsDir -ChildPath $fileName


$sqlPassword = az keyvault secret show --name sql-admin-password --vault-name $keyVaultName --query value -o tsv
$storageKey = az keyvault secret show --name storage-account-key --vault-name $keyVaultName --query value -o tsv


# download the bacpac file
# Download the file
Invoke-WebRequest -Uri $wwiBacpacUri -OutFile $outputFilePath

# get storageAccount context using the key
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName `
                            -StorageAccountKey $storageKey

# create container if not exists and copy blob
Set-AzStorageBlobContent -Context $ctx `
                         -Container "bacpacs" `
                         -Blob "$fileName" `
                         -StandardBlobTier 'Hot' `
                         -File "$outputFilePath"

az sql db import -g $rg `
                 -s $serverName `
                 -n wide_world_importers `
                 -u $sqlAdminUser `
                 -p $sqlPassword `
                 --storage-uri $storageURI `
                 --storage-key-type StorageAccessKey `
                 --storage-key $storageKey


# az sql db import -s myserver -n mydatabase -g mygroup -p password -u login --storage-key MYKEY== --storage-key-type StorageAccessKey --storage-uri https://myAccountName.blob.core.windows.net/myContainer/myBacpac.bacpac