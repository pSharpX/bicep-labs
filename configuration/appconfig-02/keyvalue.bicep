
@minLength(5)
@maxLength(50)
@description('Specifies the name of the App Configuration store. Alphanumerics, underscores, and hyphens are allowed.')
param configStoreName string

param keyName string
param keyValue string
param keyTags object

resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: '${configStoreName}/${keyName}'
  properties: {
    value: keyValue
    tags: keyTags
  }
}

output key string = configStoreKeyValue.properties.key
