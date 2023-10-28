
@minLength(5)
@maxLength(50)
@description('Specifies the name of the App Configuration store. Alphanumerics, underscores, and hyphens are allowed.')
param configStoreName string

@minLength(1)
@maxLength(50)
param keys array

var SLASH_CHAR = '/'
var ESCAPED_SLASH_CHAR = '~2F'

resource existingConfigStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing =  {
  name: configStoreName
}

/*
  Feature flag belongs to keyValues resource type. 
  To be a feature flag, the key of keyValues resource requires prefix .appconfig.featureflag/. 
  However, / is forbidden in resource's name. ~2F is used to espace the forward slash character.
*/
resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = [for param in keys: {
  parent: existingConfigStore
  name: replace(param.name, SLASH_CHAR, ESCAPED_SLASH_CHAR)
  properties: param.properties
}]

output endpoint string = existingConfigStore.properties.endpoint
output keys array = [for (key, i) in keys: configStoreKeyValue[i].properties.key]
