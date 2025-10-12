param tags object = {}

@description('A name for the key vault resource. Alphanumerics and hyphens are allowed.')
@minLength(3)
@maxLength(24)
param keyVaultName string

@minLength(1)
@maxLength(127)
@description('Specifies the name of the secret that you want to create. Alphanumerics and hyphens are allowed.')
param secretName string
@secure()
@description('Specifies the value of the secret that you want to create.')
param secretValue string

@description('Represents the current date in UTC format')
param nowUtc string = utcNow()

var add2Days = dateTimeAdd(nowUtc, 'P2D')
var epoch = dateTimeToEpoch(add2Days)


resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  name: secretName
  parent: keyVault
  properties: {
    value: secretValue
    attributes: {
      enabled: true
      exp: epoch
    }
  }
  tags: tags
}

output secretEndpoint string = keyVaultSecret.properties.secretUri
output secretEndpointWithVersion string = keyVaultSecret.properties.secretUriWithVersion
