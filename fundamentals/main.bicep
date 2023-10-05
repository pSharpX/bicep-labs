
param location string = toLower(resourceGroup().location)
param applicationId string = 'biceptor'
param sku string = 'F1'
var provisioner = 'bicep'
var owner = 'aforo255'
var environment = 'dev'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${applicationId}storageaccount'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }

  tags: {
    applicationId: applicationId
    provisioner: provisioner
    owner: owner
    environment: environment 
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${applicationId}appserviceplan'
  location: location
  sku: {
    name: sku
  }

  tags: {
    applicationId: applicationId
    provisioner: provisioner
    owner: owner
    environment: environment
  }
}

resource webApplication 'Microsoft.Web/sites@2022-09-01' = {
  name: '${applicationId}webapplication'
  location: location

  tags: {
    applicationId: applicationId
    provisioner: provisioner
    owner: owner
    environment: environment
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}


