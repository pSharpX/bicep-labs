import { locationType, keyVaultSkuTYpe } from '../types.bicep'

param location locationType
param tags object = {}

@minLength(1)
@maxLength(90)
@description('The resource name')
param keyVaultName string
param keyVaultSku keyVaultSkuTYpe = 'standard'

@description('Property to specify whether the \'soft delete\' functionality is enabled for this key vault. If it\'s not set to any value(true or false) when creating new key vault, it will be set to true by default. Once set to true, it cannot be reverted to false')
param enableSoftDelete bool = true
@description('softDelete data retention days. It accepts >=7 and <=90')
param softDeleteRetentionInDays int = 7
@description('Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored. When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. If null or not specified, the vault is created with the default value of false. Note that management actions are always authorized with RBAC.')
param enableRbacAuthorization bool = true


resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: enableRbacAuthorization
    enabledForTemplateDeployment: true
    sku: {
       name: keyVaultSku
       family: 'A'
    }
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
  tags: tags
}

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
output keyVaulUri string = keyVault.properties.vaultUri
