@description('Region in Azure where resources will be deploy')
param location string = resourceGroup().location

@description('Application Identifier')
@minLength(3)
@maxLength(8)
param applicationId string
@description('Application owner for Technical Support')
param owner string
@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string
@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string

@description('A name for the key vault resource. Alphanumerics and hyphens are allowed.')
@minLength(3)
@maxLength(24)
param keyVaultName string
param accountKeySecretName string = 'storage-accountkey'

@minLength(3)
@maxLength(24)
@description('Specifies the name of the storage account. Lowercase letters and numbers are allowed')
param storageName string = '${applicationId}${uniqueString(resourceGroup().id)}sa'
param useExistingStorageAccount bool
param shareName string = 'config'

@description('Represents the current date in UTC format')
param nowUtc string = utcNow()

var add1Month = dateTimeAdd(nowUtc, 'P1M')
var epoch = dateTimeToEpoch(add1Month)

resource existingStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = if (useExistingStorageAccount) {
  name: storageName
}

resource newStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = if (!useExistingStorageAccount) {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'  
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
  tags: {
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }
}

resource existingFileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' existing = if (useExistingStorageAccount) {
  name: 'default'
  parent: existingStorageAccount

  resource shares 'shares' = {
    name: shareName
  }
}

resource newFileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = if (!useExistingStorageAccount) {
  name: 'default'
  parent: newStorageAccount

  resource shares 'shares' = {
    name: shareName
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource accountKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: accountKeySecretName
  parent: keyVault
  properties: {
    value: useExistingStorageAccount ? existingStorageAccount.listKeys().keys[0].value: newStorageAccount.listKeys().keys[0].value
    attributes: {
      enabled: true
      exp: epoch
    }
  }
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}


output id string = useExistingStorageAccount ? existingStorageAccount.id: newStorageAccount.id
output name string = useExistingStorageAccount ? existingStorageAccount.name: newStorageAccount.name
output fileEndpoint string = useExistingStorageAccount ? existingStorageAccount.properties.primaryEndpoints.file: newStorageAccount.properties.primaryEndpoints.file
output  accountKeySecret string = accountKeySecret.name
output shareName string = useExistingStorageAccount ? existingFileService::shares.name: newFileService::shares.name
