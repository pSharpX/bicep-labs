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

@description('Specifies the name of the container app environment.')
@minLength(2)
@maxLength(32)
param containerAppEnvName string = '${applicationId}-${uniqueString(resourceGroup().id)}-env'

param logWorkspaceCustomerId string
@secure()
param logWorkspaceSharedKey string

@minLength(3)
@maxLength(24)
@description('Specifies the name of the storage account. Lowercase letters and numbers are allowed')
param storageAccountName string
@secure()
param storageAccountKey string
param fileShareName string

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name:  containerAppEnvName
  location: location
  
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logWorkspaceCustomerId
        sharedKey: logWorkspaceSharedKey
      }
    }
    vnetConfiguration: {
      internal: false
    }    
  }
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

resource fileStorage 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  name: 'azurefilestorage'
  parent: containerAppEnvironment
  properties: {
    azureFile: {
      accountName: storageAccountName
      accountKey: storageAccountKey
      shareName: fileShareName
      accessMode: 'ReadWrite'
    }
  }
} 

output id string = containerAppEnvironment.id
output storageName string = fileStorage.name
