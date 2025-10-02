import { 
  appServiceKindType 
  linuxRuntimeType
  netFrameworkVersionType
  phpVersionType
  javaVersionType
  nodeVersionType
  pythonVersionType
 } from '../types.bicep'

@minLength(3)
param location string = resourceGroup().location
@description('Tags to apply to the resources. Must be key-value pairs.')
param customTags object = {}

@minLength(1)
@maxLength(34)
@description('Must be 1-34 chars, start with a letter, only contain lowercase letters/numbers/hyphens, and end with a letter/number.')
param appName string
param servicePlanId string

param appSettings array =  []
param allowedOrigins array = []

param kind appServiceKindType
param isLinux bool = true
param runtime linuxRuntimeType = 'PYTHON|3.12'
param healthCheckPath string = ''

param netFrameworkVersion netFrameworkVersionType | '' = ''
param phpVersion phpVersionType | '' = ''
param javaVersion javaVersionType | '' = ''
param nodeVersion nodeVersionType | '' = ''
param pythonVersion pythonVersionType | '' = ''

var linuxKinds array = [ 
  'app,linux'
]

var windowsKinds array = [ 
  'app'
]

resource defaultLinuxAppService 'Microsoft.Web/sites@2024-04-01' = if (isLinux) {
  name: appName
  location: location
  kind: contains(linuxKinds, kind) ? kind: fail('Invalid kind for linux apps')
  tags: {
    application: 'onebank'
    environment: 'dev'
    owner: 'TeamDragons'
    provisioner: 'bicep'
  }
  properties: {
    serverFarmId: servicePlanId
    siteConfig: {
      linuxFxVersion: contains(linuxKinds, kind) ? runtime: fail('Invalid kind for linux apps')
      appSettings: appSettings
      healthCheckPath: !empty(healthCheckPath) ? healthCheckPath : null
      minTlsVersion: '1.2'
      cors: {
        allowedOrigins: allowedOrigins
      }
    }
    httpsOnly: true
  }
}

resource defaultWindowsAppService 'Microsoft.Web/sites@2024-04-01' = if (!isLinux) {
  name: appName
  location: location
  kind: contains(windowsKinds, kind) ? kind: fail('Invalid kind for windows apps')
  tags: {
    application: 'onebank'
    environment: 'dev'
    owner: 'TeamDragons'
    provisioner: 'bicep'
  }
  properties: {
    serverFarmId: servicePlanId
    siteConfig: {
      appSettings: appSettings
      healthCheckPath: !empty(healthCheckPath) ? healthCheckPath : null
      minTlsVersion: '1.2'
      cors: {
        allowedOrigins: allowedOrigins
      }
      ... (contains(windowsKinds, kind) ? {
        netFrameworkVersion: empty(netFrameworkVersion) ? null : netFrameworkVersion
        phpVersion: empty(phpVersion) ? null : phpVersion
        javaVersion: empty(javaVersion) ? null : javaVersion 
        nodeVersion: empty(nodeVersion) ? null : nodeVersion
        pythonVersion: empty(pythonVersion) ? null : pythonVersion
      }: {})
    }
    httpsOnly: true
  }
}

output appServiceId string = isLinux ? defaultLinuxAppService.id : defaultWindowsAppService.id
output appServiceUrl string = isLinux ? defaultLinuxAppService.?properties.hostNames[0]! : defaultWindowsAppService.?properties.hostNames[0]!
