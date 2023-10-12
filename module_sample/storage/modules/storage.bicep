
@minLength(3)
param location string = resourceGroup().location
@minLength(3)
param applicationId string
@minLength(3)
param owner string
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string
@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string
@minLength(3)
param resourceName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: resourceName
  location: location
  kind: 'StorageV2'
  tags: {
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }

  sku: {
    name: 'Standard_LRS'  
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
