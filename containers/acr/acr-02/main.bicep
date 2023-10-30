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

@description('A name for the existent key vault resource.')
@minLength(3)
@maxLength(24)
param vaultName string

module containerRegistry 'registry.bicep' = {
  name: 'registry${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    applicationId: applicationId
    containerRegistryName: containerRegistryName
    environment: environment
    owner: owner
    provisioner: provisioner
    vaultName: vaultName
  }
}

output id string = containerRegistry.outputs.id
output loginServer string = containerRegistry.outputs.loginServer
output vaultEndpoint string = containerRegistry.outputs.vaultEndpoint
output usernameSecretURI string = containerRegistry.outputs.usernameSecretURI
output passSecretURI string = containerRegistry.outputs.passSecretURI
