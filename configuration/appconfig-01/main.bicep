@description('Region in Azure where resources will be deploy')
param location string = resourceGroup().location

@description('Application Identifier')
@minLength(3)
@maxLength(10)
param applicationId string
@description('Application owner for Technical Support')
param owner string
@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string
@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string

@minLength(5)
@maxLength(50)
@description('Specifies the name of the App Configuration store. Alphanumerics, underscores, and hyphens are allowed.')
param configStoreName string = '${applicationId}${uniqueString(resourceGroup().id)}config'

@minLength(1)
@maxLength(100)
param keyValues array

@description('Adds tags for the key-value resources. It\'s optional')
param tags object = {
  'technical-owner': 'TeamGOAT'
  'data-classification': 'classified'
}


var parameters = map(keyValues, item => {
  name: '${item.name}$${environment}'
  value: item.value
  tags: contains(item, 'tags') ? item.tags: tags
})

resource configStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: configStoreName
  location: location
  sku: {
    name: 'standard'
  }
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

resource configStoreKeyValues 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = [for item in parameters: {
  parent: configStore
  name: item.name
  properties: {
    value: item.value
    tags: item.tags
  }
}]

output endppoint string = configStore.properties.endpoint
output keyValueRef array = [for (item, i) in parameters: configStoreKeyValues[i].properties.key]
