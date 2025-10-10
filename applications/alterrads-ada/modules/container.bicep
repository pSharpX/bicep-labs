
@minLength(3)
@description('Specifies the name of the blob container.')
param containerName string

@minLength(3)
@description('Specifies the name of the Azure Storage account.')
param storageAccountName string

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  name: '${storageAccountName}/default/${containerName}'
}

output containerId string = container.id
output containerName string = container.name
