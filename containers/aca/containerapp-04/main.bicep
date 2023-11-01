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

@minLength(5)
@maxLength(50)
@description('Specifies the name of the App Configuration store. Alphanumerics, underscores, and hyphens are allowed.')
param configStoreName string

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
    keyVaultName:  keyVaultName
    applicationId: applicationId
    environment: environment
    owner: owner
    provisioner: provisioner
  }
}

module storageAccount 'storage.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    location: location
    keyVaultName: keyVaultName
    useExistingStorageAccount: false
    applicationId: applicationId
    environment: environment
    owner: owner
    provisioner: provisioner 
  }
}

module appEnvironment 'environment.bicep' = {
  name: 'appEnvironmentDeployment'
  params: {
    location: location
    logWorkspaceCustomerId: logAnalyticsWorspace.outputs.customerId
    logWorkspaceSharedKey: keyVault.getSecret(logAnalyticsWorspace.outputs.primarySharedKeySecret)
    storageAccountName: storageAccount.outputs.name
    storageAccountKey: keyVault.getSecret(storageAccount.outputs.accountKeySecret)
    fileShareName: storageAccount.outputs.shareName
    applicationId: applicationId
    environment: environment
    owner: owner
    provisioner: provisioner
  }
  dependsOn: [
    logAnalyticsWorspace
    storageAccount
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
    registryLoginServer: containerRegistry.outputs.loginServer
    registryPass: keyVault.getSecret(registryPassSecretName)
    registryUsername: keyVault.getSecret(registryUsernameSecretName)
    configStoreName: configStoreName
    containerAppEnvId: appEnvironment.outputs.id
    storageName:  appEnvironment.outputs.storageName
    containerImage: containerImage
    containerName: containerName
    applicationId: applicationId
    environment: environment
    owner: owner
    provisioner: provisioner 
  }
  dependsOn: [
    appEnvironment
    containerRegistry
  ]
}
