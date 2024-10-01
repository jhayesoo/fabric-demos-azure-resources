metadata description = 'Uploads a file to an Azure Blob Storage Container.'
param name string
param location string
param storageAccountName string
param containerName string
param contentUri string
param fileName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource runPowerShellInlineWithOutput 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '8.0'
    environmentVariables: [
      {
        name: 'storageAccountKey'
        secureValue: storageAccount.listKeys().keys[0].value
      }
      {
        name: 'storageAccountName'
        value: storageAccountName
      }
      {
        name: 'containerName'
        value: containerName
      }
      {
        name: 'contentUri'
        value: contentUri
      }
      {
        name: 'fileName'
        value: fileName
      }
    ]
    scriptContent: loadTextContent('../../../scripts/copy-file-to-blob.ps1')
    timeout: 'PT4H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
