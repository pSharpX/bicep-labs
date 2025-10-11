import { 
  appServiceKindType 
  linuxRuntimeType
  locationType
 } from '../types.bicep'
 import * as globalvars from '../vars.bicep'

param location locationType

@minLength(1)
@maxLength(34)
@description('Must be 1-34 chars, start with a letter, only contain lowercase letters/numbers/hyphens, and end with a letter/number.')
param appName string
param servicePlanId string

param appSettings array =  []
param allowedOrigins array = ['*']

param kind appServiceKindType
param runtime linuxRuntimeType = 'PYTHON|3.13'
param healthCheckPath string = ''

@description('App command line to launch')
param startupCommand string = ''
@description('Repository or source control URL')
param repoUrl string = ''
@description('Name of branch to use for deployment')
param branch string = 'main'

var linuxKinds array = [ 
  'app,linux'
]

resource defaultLinuxAppService 'Microsoft.Web/sites@2024-04-01' = {
  name: appName
  location: location
  kind: contains(linuxKinds, kind) ? kind: fail('Invalid kind for linux apps')
  tags: {
    application: globalvars.application
    environment: globalvars.environment
    owner: globalvars.owner
    provisioner: globalvars.provisioner
  }
  properties: {
    serverFarmId: servicePlanId
    siteConfig: {
      linuxFxVersion: contains(linuxKinds, kind) ? runtime: fail('Invalid kind for linux apps')
      appCommandLine: !empty(startupCommand)? startupCommand: null
      appSettings: appSettings
      healthCheckPath: !empty(healthCheckPath) ? healthCheckPath : null
      minTlsVersion: '1.2'
      cors: {
        allowedOrigins: allowedOrigins
      }
    }
    httpsOnly: true
  }

  resource sourceControl 'sourcecontrols@2024-11-01' =  if (!empty(repoUrl)) {
    name: 'web'
    properties: {
      repoUrl: repoUrl
      branch: branch
      isManualIntegration: true
    }
  }
}


output appServiceId string = defaultLinuxAppService.id
output appServiceHostname string = defaultLinuxAppService.?properties.hostNames[0]!
output appServiceUrl string = 'https://${defaultLinuxAppService.?properties.hostNames[0]!}'
