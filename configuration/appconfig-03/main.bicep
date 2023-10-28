@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string

@minLength(5)
@maxLength(50)
@description('Specifies the name of the App Configuration store. Alphanumerics, underscores, and hyphens are allowed.')
param configStoreName string

@minLength(1)
@maxLength(50)
param keyValues array

@description('Adds tags for the key-value resources. It\'s optional')
param tags object = {
  'technical-owner': 'TeamGOAT'
  'data-classification': 'classified'
}

var parameters = map(keyValues, item => {
  name: (item.type == 'feature_flag') ? '.appconfig.featureflag~2F${item.name}$${environment}'
        : '${item.name}$${environment}'
  properties: (item.type == 'feature_flag') ? {
      value: string({
        id: item.name
        description: item.description
        enabled: item.enabled
      })
      tags: contains(item, 'tags') ? item.tags: tags
      contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
    } : (item.type == 'keyvault_ref') ? {
      value: string({
        uri: item.secretUrl
      })
      tags: contains(item, 'tags') ? item.tags: tags
      contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
    } : {
      value: item.value
      tags: contains(item, 'tags') ? item.tags: tags
    } 
})

module configStoreKeyValues 'keyvalue.bicep' = {
  name: 'deploy${configStoreName}${uniqueString(resourceGroup().id)}'
  params: {
    configStoreName: configStoreName
    keys: parameters
  }
}
