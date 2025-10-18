import { fileShareAccessTierType, fileShareQuota, fileServiceProtocolType } from '../types.bicep'

@minLength(3)
@description('Specifies the name of the file share.')
param shareName string
param accessTier fileShareAccessTierType = 'TransactionOptimized'
param shareQuota fileShareQuota = 10
param enabledProtocol fileServiceProtocolType = 'smb'


@minLength(3)
@description('Specifies the name of the Azure Storage account.')
param storageAccountName string

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2025-01-01' = {
  name: '${storageAccountName}/default/${shareName}'
  properties:{
    accessTier: accessTier
    enabledProtocols: toUpper(enabledProtocol)
    shareQuota: shareQuota
  }
}

output shareId string = share.id
output shareName string = share.name
