# copy the file to the local disk
Invoke-WebRequest -Uri "${env:contentUri}" -OutFile "${env:fileName}"

# get storageAccount context using the key
$ctx = New-AzStorageContext -StorageAccountName "${Env:storageAccountName}" -StorageAccountKey "${Env:storageAccountKey}"

# create container if not exists
# New-AzStorageContainer -Name "${Env:containerName}" -Context $ctx -Permission Blob

# copy blob
Set-AzStorageBlobContent -Context $ctx `
                         -Container "${Env:containerName}" `
                         -Blob "${env:fileName}" `
                         -StandardBlobTier 'Hot' `
                         -File "${env:fileName}"