@minLength(3)
@description('Specifies the location in which the Azure Storage resources should be deployed.')
param location string = resourceGroup().location

@minLength(3)
@maxLength(15)
param applicationId string

@description('Application owner for Technical Support')
param owner string

@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string

@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string

@minLength(3)
@maxLength(10)
@description('Represents the Prefix name to be used for naming all Azure Resources. Must be valid string')
param resourceNamePrefix string
param utcValue string = sys.utcNow('u')

@minValue(1)
@maxValue(5)
param containerCount int = 1

var storageAccountName = '${resourceNamePrefix}${uniqueString(resourceGroup().id, utcValue)}sa'

var containersName = [for i in range(0, containerCount): {
  name: '${resourceNamePrefix}-${uniqueString(resourceGroup().id, utcValue, string(i))}'
}]

module storageAccount 'modules/storage.bicep' = {
  name: 'defaultStorageAccount'
  params: {
    applicationId: applicationId
    owner: owner
    environment: environment
    provisioner: provisioner
    location: location
    resourceName: storageAccountName
  }
}

module containers 'modules/container.bicep' = [for container in containersName: {
  name: 'container${uniqueString(resourceGroup().id, container.name)}'
  params: {
    containerName: container.name
    storageAccountName: storageAccount.outputs.storageAccountName
  }
}]

output storageAccountBlobEndpoint string = storageAccount.outputs.blobEndpoint
