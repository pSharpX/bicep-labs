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

param containerRegistryName string

@description('A name for the existent key vault resource.')
@minLength(3)
@maxLength(24)
param vaultName string

@description('Specifies the name of the secret that you want to create. Alphanumerics and hyphens are allowed.')
var usernameSecretName = 'registry-username'
@description('Specifies the name of the secret that you want to create. Alphanumerics and hyphens are allowed.')
var passwordSecretName = 'registry-password'

@description('Represents the current date in UTC format')
param nowUtc string = utcNow()

var add5Days = dateTimeAdd(nowUtc, 'P5D')
var epoch = dateTimeToEpoch(add5Days)

var  pullScopedMap = resourceId('Microsoft.ContainerRegistry/registries/scopeMaps', containerRegistryName, '_repositories_pull')
var  pushScopedMap = resourceId('Microsoft.ContainerRegistry/registries/scopeMaps', containerRegistryName, '_repositories_push')

var pullScopedToken = 'pullScopedToken'
var pushScopedToken = 'pushScopedToken'

var registryRole = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Standard'
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

resource pullScopedRegistryToken 'Microsoft.ContainerRegistry/registries/tokens@2023-07-01' = {
  name: pullScopedToken
  parent: containerRegistry
  properties: {
    scopeMapId: pullScopedMap
    status: 'enabled'
  }
}

resource pushScopedRegistryToken 'Microsoft.ContainerRegistry/registries/tokens@2023-07-01' = {
  name: pushScopedToken
  parent: containerRegistry
  properties: {
    scopeMapId: pushScopedMap
    status: 'enabled'
  }
}

resource acrManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'acrManagedIdentity${applicationId}'
  location: location
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, acrManagedIdentity.id, registryRole)
  properties: {
    principalId: acrManagedIdentity.properties.principalId
    roleDefinitionId: registryRole
    principalType: 'ServicePrincipal'
  }
}

resource pullScopedTokenPasswordGenerator 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'pullScopedTokenPasswordGeneratorScript'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${acrManagedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.52.0'
    retentionInterval: 'PT1H'
    timeout: 'PT5M'
    environmentVariables: [
      {
        name: 'ACR_NAME'
        value: containerRegistryName
      }
      {
        name: 'TOKEN_NAME'
        value: pullScopedToken
      }
      {
        name: 'TOKEN_EXPIRATION_IN_DAYS'
        value: '10'
      }
    ]
    scriptContent: 'az acr token credential generate -n $TOKEN_NAME -r $ACR_NAME --expiration-in-days $TOKEN_EXPIRATION_IN_DAYS'
  }

  dependsOn: [
    containerRegistry
    pullScopedRegistryToken
    acrRoleAssignment
  ]
}

resource pushScopedTokenPasswordGenerator 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'pushScopedTokenPasswordGeneratorScript'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${acrManagedIdentity.id}': {}
    }
  }
  properties: {
    environmentVariables: [
      {
        name: 'ACR_NAME'
        value: containerRegistryName
      }
      {
        name: 'TOKEN_NAME'
        value: pushScopedToken
      }
      {
        name: 'TOKEN_EXPIRATION_IN_DAYS'
        value: '10'
      }
    ]
    azCliVersion: '2.52.0'
    retentionInterval: 'PT1H'
    timeout: 'PT5M'
    scriptContent: 'az acr token credential generate -n $TOKEN_NAME -r $ACR_NAME --expiration-in-days $TOKEN_EXPIRATION_IN_DAYS'
  }

  dependsOn: [
    containerRegistry
    pushScopedRegistryToken
  ]
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: vaultName
}

resource usernameSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: usernameSecretName
  parent: keyVault
  properties: {
    value: containerRegistry.listCredentials().username
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

resource passwordSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: passwordSecretName
  parent: keyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
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

output id string = containerRegistry.id
output loginServer string = containerRegistry.properties.loginServer
output vaultEndpoint string = keyVault.properties.vaultUri
output usernameSecretURI string = usernameSecret.properties.secretUriWithVersion
output passSecretURI string = passwordSecret.properties.secretUriWithVersion
