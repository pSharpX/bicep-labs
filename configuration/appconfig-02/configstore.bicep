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

resource newConfigStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = if (!useExistingConfigStore) {
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

resource existingConfigStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = if (useExistingConfigStore) {
  name: configStoreName
}

output endpoint string = useExistingConfigStore ? existingConfigStore.properties.endpoint: newConfigStore.properties.endpoint
