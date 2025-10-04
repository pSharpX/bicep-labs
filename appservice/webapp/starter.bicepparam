using 'starter.bicep'

param resourceGroupName = 'rg-onebank-dev'
param location = 'westus3'

param environment = 'dev'
param applicationId = 'onebank'
param owner = 'Team_Dragons'
param provisioner = 'bicep'

var sku = 'F1'

param apps = [
  {
    appName: 'onebank-bookstore'
    appKind: 'app,linux'
    appSettings: [
      {name: 'ENV', value: 'DEVELOPMENT'}
    ]
    serverKind: 'app,linux'
    skuName: sku
    isLinux: true
    customProperties: {
      runtime: 'JAVA|21-java21'
    }
  }

  {
    appName: 'onebank-bookstore'
    appKind: 'app,linux'
    appSettings: [
      {name: 'ENV', value: 'DEVELOPMENT'}
    ]
    serverKind: 'app,linux'
    skuName: sku
    isLinux: true
    customProperties: {
      runtime: 'DOTNETCORE|10.0'
    }
  }
  {
    appName: 'onebank-bookstore'
    appKind: 'app'
    appSettings: [
      {name: 'ENV', value: 'DEVELOPMENT'}
    ]
    serverKind: 'app'
    skuName: sku
    isLinux: false
    customProperties: {
      nodeVersion: '20-lts' 
    }
  }
  {
    appName: 'onebank-bookstore'
    appKind: 'app'
    appSettings: [
      {name: 'ENV', value: 'DEVELOPMENT'}
    ]
    serverKind: 'app'
    skuName: sku
    isLinux: false
    customProperties: {
      pythonVersion: '3.11'
    }
  }
]
