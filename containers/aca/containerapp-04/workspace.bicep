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

@description('Specifies the name of the log analytics workspace.Alphanumerics and hyphens are allowed.')
@minLength(4)
@maxLength(63)
param logWorkspaceName string = '${applicationId}-${uniqueString(resourceGroup().id)}-workspace'
param sharedKeySecretName string = 'workspace-sharedkey'

@description('Represents the current date in UTC format')
param nowUtc string = utcNow()

var add1Month = dateTimeAdd(nowUtc, 'P1M')
var epoch = dateTimeToEpoch(add1Month)

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
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

resource sharedKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: sharedKeySecretName
  parent: keyVault
  properties: {
    value: logAnalyticsWorkspace.listKeys().primarySharedKey
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

output id string = logAnalyticsWorkspace.id
output customerId string = logAnalyticsWorkspace.properties.customerId
output primarySharedKeySecret string = sharedKeySecretName
