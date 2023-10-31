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

output id string = containerAppEnvironment.id
