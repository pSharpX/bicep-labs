@description('Region in Azure where resources will be deploy')
param location string = resourceGroup().location

@description('Application Identifier')
@minLength(3)
@maxLength(10)
param applicationId string
@description('Application owner for Technical Support')
param owner string
@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string
@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string

@description('Provide a globally unique name of your Azure Container Registry')
@minLength(5)
@maxLength(50)
param containerRegistryName string = '${applicationId}${uniqueString(resourceGroup().id)}acr'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }

  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

output id string = containerRegistry.id
output loginServer string = containerRegistry.properties.loginServer
output username string = containerRegistry.listCredentials().username
// It's not recommended to output secrets, token or any kind of sensible information. This is only for practical purpose.
output password string = containerRegistry.listCredentials().passwords[0].value
