targetScope = 'subscription'

// The main bicep module to provision Azure resources.
// For a more complete walkthrough to understand how this file works with azd,
// see https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Optional parameters to override the default azd resource naming conventions.
// Add the following to main.parameters.json to provide values:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param resourceGroupName string

param resourcePrefix string
param resourceSuffix string

param principalId string = ''

param upn string = ''

@description('Create a login name for SQL authentication')
param sqlAuthAdminLogin string

@description('Create a password for SQL authentication')
@secure()
param sqlAuthAdminPassword string
var abbrs = loadJsonContent('./abbreviations.json')

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': environmentName
  }

var wwiBacpacUri = 'https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Standard.bacpac'

var vprefix = toLower('${resourcePrefix}')
var vsuffix = toLower('${resourceSuffix}')

var keyVaultName = '${vprefix}-${abbrs.keyVaultVaults}${vsuffix}'
var storageAccountName = '${replace(vprefix,'-','0')}0${abbrs.storageStorageAccounts}0${replace(vsuffix,'-','0')}'
var sqlServerName = '${vprefix}-${abbrs.sqlServers}${vsuffix}'

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Deploy Key Vault
module keyvault './core//security/keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    location: location
    name: keyVaultName
    tags: tags
    principalId: principalId
   }
 }

 module sqlAuthAdminPasswordSecret './core/security/keyvault-secret.bicep' = {
  name: 'sqlAuthAdminPasswordSecret'
  scope: rg
  params: {
    keyVaultName: keyVaultName
    name: 'sql-admin-password'
    secretValue: sqlAuthAdminPassword
  }
  dependsOn: [
    keyvault
  ]
}
module storageAccount './core/storage/storage-account.bicep' = {
  name: 'storageAccount'
  scope: rg
  params: {
    name: storageAccountName
    location: location
    keyVaultName: keyVaultName
    containers:[
      { 
        name:'bacpacs'
      }
      {
      name: 'scenario1-validatecsv'
      }
    ]
    tags: tags
  }
  dependsOn: [
    keyvault
]
}

/* module storageUploadFile './core/storage/storage-upload-file.bicep' = {
  name: 'storageUploadFile'
  scope: rg
  params: {
    name: 'wwiBacpac'
    location: location
    fileName: 'WideWorldImporters-Standard.bacpac'
    storageAccountName: storageAccountName
    containerName: 'bacpacs'
    contentUri: wwiBacpacUri
  }
  dependsOn: [
      storageAccount
      keyvault
  ]
}
*/

module sqlServer './core/database/sqlserver/sqlserver.bicep' = {
  name: 'sqlServer'
  scope: rg
  params: {
    name: sqlServerName
    location: location
    tags: tags
    principalId: principalId
    upn: upn
    sqlAuthAdminLogin: sqlAuthAdminLogin
    sqlAuthAdminPassword: sqlAuthAdminPassword
  }
  dependsOn: [
    storageAccount
    //storageUploadFile
    keyvault
  ]
}


// Add resources to be provisioned below.
// A full example that leverages azd bicep modules can be seen in the todo-python-mongo template:
// https://github.com/Azure-Samples/todo-python-mongo/tree/main/infra



// Add outputs from the deployment here, if needed.
//
// This allows the outputs to be referenced by other bicep deployments in the deployment pipeline,
// or by the local machine as a way to reference created resources in Azure for local development.
// Secrets should not be added here.
//
// Outputs are automatically saved in the local azd environment .env file.
// To see these outputs, run `azd env get-values`,  or `azd env get-values --output json` for json output.
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_UPN string = upn
output AZURE_PRINCIPAL_ID string = principalId
output AZURE_RESOURCE_GROUP_NAME string = rg.name
output AZURE_KEYVAULT_NAME string = keyVaultName
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccountName
output AZURE_SQL_SERVER_NAME string = sqlServerName
output AZURE_SQL_SERVER_ADMIN_LOGIN string = sqlAuthAdminLogin



