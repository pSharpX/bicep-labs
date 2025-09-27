
@minLength(3)
param location string = resourceGroup().location
param tags object = {}

@minLength(3)
@maxLength(24)
@description('The field can contain only lowercase letters and numbers. Name must be between 3 and 24 characters.')
param resourceName string

@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param kind string = 'StorageV2'

@allowed([
  'Premium_LRS'
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
])
param sku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: resourceName
  location: location
  kind: kind
  tags: tags
  sku: {
    name: sku
  }

  properties: {
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
