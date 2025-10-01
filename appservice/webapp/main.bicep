
targetScope = 'subscription'

@minLength(3)
@maxLength(24)
@description('Can contains alpanumric characters and dash')
param resourceGroupName string

@minLength(1)
@maxLength(34)
@description('Must be 1-34 chars, only letters/numbers/hyphen, cannot start/end with hyphen.')
param linuxServicePlan string
@minLength(1)
@maxLength(34)
@description('Must be 1-34 chars, only letters/numbers/hyphen, cannot start/end with hyphen.')
param windowsServicePlan string

@minLength(1)
@maxLength(34)
@description('Must be 1-34 chars, start with a letter, only contain lowercase letters/numbers/hyphens, and end with a letter/number.')
param linuxAppServiceName string
@minLength(1)
@maxLength(34)
@description('Must be 1-34 chars, start with a letter, only contain lowercase letters/numbers/hyphens, and end with a letter/number.')
param windowsAppServiceName string

@allowed([
  'eastus'
  'westeurope'
  'centralus'
])
param location string = 'eastus'

@allowed([ 'dev', 'test', 'stagging', 'prod'])
param environment string = 'dev'

@minLength(3)
@maxLength(20)
@description('It represents the owner of the application. Must contains alpanumric chararacters and dash')
param applicationId string = 'onebank'

@allowed([
  'bicep'
  'terraform'
  'pulumi'
  'arm'
])
param provisioner string = 'bicep'

@minLength(3)
@maxLength(20)
@description('It represents the owner of the application. Must contains alpanumric chararacters and dash')
param owner string = 'TeamDragons'

var tags = {
  application: applicationId
  environment: environment
  owner: owner
  provisioner: provisioner
}

resource onebankRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module defaultLinuxServicePlan 'modules/serviceplan.bicep' = {
  name:'defaultLinuxServicePlan'
  scope:onebankRG
  params:{
    resourceName:linuxServicePlan
    skuName: 'F1'
    kind: 'app,linux'
    tags:tags
  }
}

module defaultWindowsServicePlan 'modules/serviceplan.bicep' = {
  name:'defaultWindowsServicePlan'
  scope:onebankRG
  params:{
    resourceName:windowsServicePlan
    skuName: 'F1'
    kind: 'app'
    tags:tags
  }
}

module defaultLinuxAppService 'modules/appservice.bicep' = {
  name:'defaultLinuxAppService'
  scope:onebankRG
  params:{
    resourceName: linuxAppServiceName
    isLinux: true
    kind: 'app,linux'
    appSettings: [
      {
        name: 'ENV'
        value: 'DEVELOP'
      }
    ]
    servicePlanId: defaultLinuxServicePlan.outputs.servicePlanId
    runtime: 'JAVA:11-java11'
    tags:tags
  }
}

module defaultWindowsAppService 'modules/appservice.bicep' = {
  name:'defaultWindowsAppService'
  scope:onebankRG
  params:{
    resourceName: windowsAppServiceName
    isLinux: false
    kind: 'app'
    appSettings: [
      {
        name: 'ENV'
        value: 'DEVELOP'
      }
    ]
    servicePlanId: defaultWindowsServicePlan.outputs.servicePlanId
    javaVersion: '11'
    tags:tags
  }
}

output resourceGroupId string = onebankRG.id
output linuxAppServiceId string = defaultLinuxAppService.outputs.appServiceId
output windowsAppServiceId string = defaultWindowsAppService.outputs.appServiceId
output linuxAppServiceUrl string = defaultLinuxAppService.outputs.appServiceUrl
output windowsAppServiceUrl string = defaultWindowsAppService.outputs.appServiceUrl
