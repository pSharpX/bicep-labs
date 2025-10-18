import { storageKindType, storageSkuType, storageAccountNameType, storageAccessTierType, fileServiceProtocolType } from '../types.bicep'

@description('Region where resource will be created')
param location string
param tags object = {}

param resourceName storageAccountNameType
param kind storageKindType = 'StorageV2'
param skuName storageSkuType = 'Standard_LRS'
param accessTier storageAccessTierType = 'Hot'
param enableVersioning bool = false

param enableBlobStorage bool = true
param enableFileShared bool = false
param enableQueueStorage bool = false
param enableTableStorage bool = false

param containers string[] = []
param fileshares string[] = []

param fileServiceProtocol fileServiceProtocolType = 'smb'

var fileSharedSettings object = {
  smb: {
    protocolSettings: {
      smb: {}
    }
  }
  nfs: {
    protocolSettings: {
      nfs: {}
    }
  }
}


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: resourceName
  kind: kind
  sku: {
    name: skuName
  }
  location: location
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    accessTier: accessTier
    supportsHttpsTrafficOnly: true
    immutableStorageWithVersioning: {
      enabled: enableVersioning
    }
  }
  tags: tags

  resource blobStorage 'blobServices@2025-01-01' = if (enableBlobStorage) {
    name: 'default'
    properties: {
      isVersioningEnabled: enableVersioning
      automaticSnapshotPolicyEnabled: false
      containerDeleteRetentionPolicy: {
        allowPermanentDelete:false
        enabled:true
        days: 7
      }
      deleteRetentionPolicy: {
        allowPermanentDelete:false
        days: 7
        enabled: true
      }
    }

    resource containerResources 'containers@2025-01-01' = [for (item, index) in containers: {
      name: item
      properties: {
        immutableStorageWithVersioning: {
          enabled: false
        }
        publicAccess: 'None'        
      }      
    }]
  }

  resource fileShared 'fileServices@2025-01-01' = if (enableFileShared) {
    name: 'default'
    properties:{
      shareDeleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: true
        days: 7
      }
      ...fileSharedSettings[fileServiceProtocol]
    }

    resource fileShareResources 'shares@2025-01-01' = [for (item, index) in fileshares: {
      name: item
      properties: {
        accessTier: 'TransactionOptimized'
        enabledProtocols: 'SMB'
        shareQuota: 10
      }
    }]
  }

  resource queueStorage 'queueServices@2025-01-01' = if (enableQueueStorage) {
    name: 'default'
  }

  resource tableStorage 'tableServices@2025-01-01' = if (enableTableStorage) {
    name: 'default'
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
@secure()
output storageDefaultKey string = storageAccount.listKeys().keys[0].value
