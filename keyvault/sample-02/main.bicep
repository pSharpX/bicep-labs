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
param keyVaultName string

@description('The name or identifier for accessing the secret in key vault. Alphanumerics and hyphens are allowed.')
@minLength(1)
@maxLength(127)
param secretName string
@secure()
param secretValue string


@description('Represents the current date in UTC format')
param nowUtc string = utcNow()

var add2Days = dateTimeAdd(nowUtc, 'P2D')
var epoch = dateTimeToEpoch(add2Days)

resource aforo255KeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource databaseSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: secretName
  parent: aforo255KeyVault
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

output vaultEndpoint string = aforo255KeyVault.properties.vaultUri
output secretEndpoint string = databaseSecret.properties.secretUri
