@description('Region in Azure where resources will be deploy')
param location string = resourceGroup().location

@description('Application Identifier')
@minLength(3)
@maxLength(6)
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
param keyVaultName string = '${applicationId}-${uniqueString(resourceGroup().id)}-kv'

@description('Specifies the name of the secret that you want to create. Alphanumerics and hyphens are allowed.')
@minLength(1)
@maxLength(127)
param secretName string
@secure()
@description('Specifies the value of the secret that you want to create.')
param secretValue string

@minLength(1)
@maxLength(128)
@description('Represents the name or identifier for the identity. Alphanumerics, hyphens, and underscores are allowed')
param msiName string = '${applicationId}-${uniqueString(resourceGroup().id)}-msi'

@description('Represents the current date in UTC format')
param nowUtc string = utcNow()

var add2Days = dateTimeAdd(nowUtc, 'P2D')
var epoch = dateTimeToEpoch(add2Days)

var secretUserRole = resourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: msiName
  location: location

  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

resource secretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, managedIdentity.id, secretUserRole)
  scope: keyVault
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: secretUserRole
    principalType: 'ServicePrincipal'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location

  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    sku: {
       name: 'standard'
       family: 'A'
    }
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }

  resource keyVaultSecret 'secrets@2023-02-01' = {
    name: secretName
    properties: {
      value: secretValue
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
}

output keyVaultId string = keyVault.id
output vaultEndpoint string = keyVault.properties.vaultUri
output secretEndpoint string = keyVault::keyVaultSecret.properties.secretUriWithVersion
