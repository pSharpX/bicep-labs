
targetScope = 'subscription'

@minLength(3)
@maxLength(24)
@description('Must contains alpanumric chararacters and dash')
param resourceGroupName string

@minLength(3)
@maxLength(24)
@description('The field can contain only lowercase letters and numbers. Name must be between 3 and 24 characters.')
param storageAccountName string

@allowed([
  'eastus'
  'westeurope'
  'centralus'
])
param location string = 'eastus'

@allowed([ 'dev', 'test', 'stagging', 'prod'])
param environment string = 'dev'

@minLength(3)
@maxLength(20)
@description('It represents the owner of the application. Must contains alpanumric chararacters and dash')
param applicationId string = 'onebank'

@allowed([
  'bicep'
  'terraform'
  'pulumi'
  'arm'
])
param provisioner string = 'bicep'

@minLength(3)
@maxLength(20)
@description('It represents the owner of the application. Must contains alpanumric chararacters and dash')
param owner string = 'TeamDragons'

var tags = {
  application: applicationId
  environment: environment
  owner: owner
  provisioner: provisioner
}

resource onebankRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module onebankStorageAcount 'modules/storage.bicep' = {
  name: 'defaultStorageAccount'
  scope: onebankRG
  params: {
    resourceName: storageAccountName
    tags: tags
  }
}


output resourceGroupId string = onebankRG.id
output storageAccountId string = onebankStorageAcount.outputs.storageAccountId
output blobEndpoint string = onebankStorageAcount.outputs.blobEndpoint
