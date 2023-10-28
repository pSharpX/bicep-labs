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
param configStoreName string
param useExistingConfigStore bool

@minLength(1)
@maxLength(100)
param keyValues array

var SLASH_CHAR = '/'
var ESCAPED_SLASH_CHAR = '~2F'

@description('Adds tags for the key-value resources. It\'s optional')
param tags object = {
  'technical-owner': 'TeamGOAT'
  'data-classification': 'classified'
}

var parameters = map(keyValues, item => {
  name: '${replace(item.name, SLASH_CHAR, ESCAPED_SLASH_CHAR)}$${environment}'
  value: item.value
  tags: contains(item, 'tags') ? item.tags: tags
})

module configStore 'configstore.bicep' = {
  name: 'deploy${configStoreName}'
  params: {
    configStoreName: configStoreName
    useExistingConfigStore: useExistingConfigStore
    location: location
    applicationId: applicationId
    environment: environment
    owner: owner
    provisioner: provisioner
  }
}

module configStoreKeyValues 'keyvalue.bicep' = [for item in parameters: {
  name: 'deploy${configStoreName}${uniqueString(item.name)}'
  params: {
    configStoreName: configStoreName
    keyName: item.name
    keyValue: item.value
    keyTags: item.tags
  }
  dependsOn: [
    configStore
  ]
}]

output endppoint string = configStore.outputs.endpoint
output keyValueRef array = [for (item, i) in parameters: configStoreKeyValues[i].outputs.key]
