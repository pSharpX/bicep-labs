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

@description('Provide a globally unique name of your Azure Container Registry. Alphanumerics are allowed')
@minLength(5)
@maxLength(50)
param containerRegistryName string
param registryUsernameSecretName string
param registryPassSecretName string

@description('Specifies the docker container image to deploy.')
param containerImage string

@description('Specifies the docker container name')
param containerName string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

module logAnalyticsWorspace 'workspace.bicep' = {
  name: 'logAnalyticsWorspaceDeployment'
  params: {
    location: location
    applicationId: applicationId
    environment: environment
    keyVaultName:  keyVaultName
    owner: owner
    provisioner: provisioner
  }
}

module appEnvironment 'environment.bicep' = {
  name: 'appEnvironmentDeployment'
  params: {
    location: location
    applicationId: applicationId
    environment: environment
    logWorkspaceCustomerId: logAnalyticsWorspace.outputs.customerId
    logWorkspaceSharedKey: keyVault.getSecret(logAnalyticsWorspace.outputs.primarySharedKeySecret)
    owner: owner
    provisioner: provisioner
  }
  dependsOn: [
    logAnalyticsWorspace
  ]
}

module containerRegistry 'registry.bicep' = {
  name: 'containerRegistryDeployment'
  params:{
    location: location
    applicationId: applicationId
    environment: environment
    keyVaultName: keyVaultName
    owner: owner
    provisioner: provisioner 
    registryPassSecretName: registryUsernameSecretName
    registryUsernameSecretName: registryPassSecretName
    useExistentContainerRegistry: true
    containerRegistryName: containerRegistryName
  }
}

module containerApp 'container.bicep' = {
  name: 'containerAppDeployment'
  params: {
    location: location
    applicationId: applicationId
    containerAppEnvId: appEnvironment.outputs.id
    containerImage: containerImage
    containerName: containerName
    environment: environment
    owner: owner
    provisioner: provisioner 
    registryLoginServer: containerRegistry.outputs.loginServer
    registryPass: keyVault.getSecret(registryPassSecretName)
    registryUsername: keyVault.getSecret(registryUsernameSecretName)
  }
  dependsOn: [
    appEnvironment
    containerRegistry
  ]
}
