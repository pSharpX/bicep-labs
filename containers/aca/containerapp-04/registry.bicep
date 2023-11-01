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
param containerRegistryName string = '${applicationId}${uniqueString(resourceGroup().id)}acr'
param useExistentContainerRegistry bool

param registryUsernameSecretName string
param registryPassSecretName string

@description('Represents the current date in UTC format')
param nowUtc string = utcNow()

var add1Month = dateTimeAdd(nowUtc, 'P1M')
var epoch = dateTimeToEpoch(add1Month)

resource existentContainerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = if (useExistentContainerRegistry) {
  name: containerRegistryName
}

resource newContainerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = if (!useExistentContainerRegistry) {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    adminUserEnabled: true
  }
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource registryUsernameSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!useExistentContainerRegistry) {
  name: registryUsernameSecretName
  parent: keyVault
  properties: {
    value: newContainerRegistry.listCredentials().username
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

resource registryPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!useExistentContainerRegistry) {
  name: registryPassSecretName
  parent: keyVault
  properties: {
    value: newContainerRegistry.listCredentials().passwords[0].value
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

output id string = useExistentContainerRegistry ? existentContainerRegistry.id: newContainerRegistry.id
output loginServer string = useExistentContainerRegistry ? existentContainerRegistry.properties.loginServer: newContainerRegistry.properties.loginServer
output usernameSecretName string = useExistentContainerRegistry ? registryUsernameSecretName: registryUsernameSecret.name
output passSecretName string = useExistentContainerRegistry ? registryPassSecretName: registryPasswordSecret.name
