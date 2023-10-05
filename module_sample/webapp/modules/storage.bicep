@description('Region where resource will be created')
param location string

@description('Application Identifier')
@minLength(3)
@maxLength(15)
param applicationId string
@description('Application owner for Technical Support')
param owner string
@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string
@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string

@minLength(3)
@description('Name of the resource. Must be valid name')
param resourceName string = toLower('${applicationId}sa${environment}')

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: resourceName
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
  location: location
  
  properties: {
    accessTier: 'Hot'
  }

  tags: {
    applicationId: applicationId
    owner: owner
    environment: environment
    provisioner: provisioner
  }
}

output storageAccountId string = storageAccount.id
