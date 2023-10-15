
@minLength(3)
@description('Represents the name for the existing Storage Account Resource')
param storageAccountName string

@minLength(3)
param containerName string

@description('Azure Resource Group name where Storage Account Resource was deployed')
param saResourceGroupName string
@description('Existent file(blob) in container')
param filename string

param baseTime string = utcNow('u')

var add1Hour = dateTimeAdd(baseTime, 'PT1H')

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
  scope: resourceGroup(saResourceGroupName)
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
  name: 'default'
  parent: storageAccount
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' existing = {
  name: containerName
  parent: blobService
}

// Further information visit the following link: https://learn.microsoft.com/en-us/rest/api/storageservices/create-service-sas
var serviceSasTokenForContainer = storageAccount.listServiceSas('2023-01-01', {
  canonicalizedResource: '/blob/${storageAccount.name}/${container.name}'
  signedExpiry: add1Hour
  signedPermission: 'r'
  signedResource: 'c'
  signedProtocol: 'https'
}).serviceSasToken

var serviceSasTokenForBlob = storageAccount.listServiceSas('2023-01-01', {
  canonicalizedResource: '/blob/${storageAccount.name}/${container.name}/${filename}'
  signedExpiry: add1Hour
  signedPermission: 'r'
  signedResource: 'b'
  signedProtocol: 'https'
}).serviceSasToken

// Futher information visit the following link: https://learn.microsoft.com/en-us/rest/api/storageservices/create-account-sas


output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output ssasTokenForContainer string = serviceSasTokenForContainer
output ssasTokenForBlob string = serviceSasTokenForBlob
output blobPermissionFileURI string = '${storageAccount.properties.primaryEndpoints.blob}${container.name}/${filename}?${serviceSasTokenForBlob}'
output containerPermissionFileURI string = '${storageAccount.properties.primaryEndpoints.blob}${container.name}/${filename}?${serviceSasTokenForContainer}'
