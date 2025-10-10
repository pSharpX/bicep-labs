import { storageKindType, storageSkuType, storageAccountNameType } from '../types.bicep'

@description('Region where resource will be created')
param location string
param tags object = {}

param resourceName storageAccountNameType
param kind storageKindType = 'StorageV2'
param skuName storageSkuType = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: resourceName
  kind: kind
  sku: {
    name: skuName
  }
  location: location
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
  tags: tags

  resource blobStorage 'blobServices@2025-01-01' = {
    name: 'default'
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
@secure()
output storageDefaultKey string = storageAccount.listKeys().keys[0].value
