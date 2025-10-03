
import { appConfigListType, locationType, servicePlanSkuType } from 'types.bicep'

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

param sku servicePlanSkuType 

@minLength(1)
@maxLength(34)
@description('Must be 1-34 chars, start with a letter, only contain lowercase letters/numbers/hyphens, and end with a letter/number.')
param linuxAppServiceName string
@minLength(1)
@maxLength(34)
@description('Must be 1-34 chars, start with a letter, only contain lowercase letters/numbers/hyphens, and end with a letter/number.')
param windowsAppServiceName string

param location locationType = 'eastus'


@description('It represent the number of apps will be provisioned. Must contain server information and app details')
param apps appConfigListType = []

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

var tags object = {
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
    skuName: sku
    kind: 'app,linux'
    tags:tags
  }
}

module defaultWindowsServicePlan 'modules/serviceplan.bicep' = {
  name:'defaultWindowsServicePlan'
  scope:onebankRG
  params:{
    resourceName:windowsServicePlan
    skuName: sku
    kind: 'app'
    tags:tags
  }
}

module defaultLinuxAppService 'modules/appservice.bicep' = {
  name:'defaultLinuxAppService'
  scope:onebankRG
  params:{
    appName: linuxAppServiceName
    kind: 'app,linux'
    appSettings: [
      {
        name: 'ENV'
        value: 'DEVELOP'
      }
    ]
    servicePlanId: defaultLinuxServicePlan.outputs.servicePlanId
    runtime: 'JAVA|11-java11'
  }
}

module defaultWindowsAppService 'modules/appservice.bicep' = {
  name:'defaultWindowsAppService'
  scope:onebankRG
  params:{
    appName: windowsAppServiceName
    isLinux: false
    kind: 'app'
    appSettings: [
      {
        name: 'ENV'
        value: 'DEVELOP'
      }
    ]
    servicePlanId: defaultWindowsServicePlan.outputs.servicePlanId
    netFrameworkVersion: 'v3.5'
  }
}

module onebankServicePlans 'modules/serviceplan.bicep' = [for (app, i) in apps: {
  name: 'deployment-asp-${app.appName}-${i}-${environment}'
  scope: onebankRG
  params: {
    resourceName: 'asp-${app.appName}-${environment}-${i}'
    skuName: app.skuName
    kind: app.serverKind
    tags:tags
  }
}]

module onebankAppServices 'modules/appservice.bicep' = [for (app, i) in apps: {
  name: 'deployment-web-${app.appName}-${i}-${environment}'
  scope:onebankRG
  params: {
    appName: 'web-${app.appName}-${i}-${environment}'
    repoUrl: app.?sourceControl.?repoUrl
    branch: app.?sourceControl.?branch
    startupCommand: app.?startupCommand
    isLinux: app.isLinux
    kind: app.appKind
    appSettings: app.appSettings
    servicePlanId: onebankServicePlans[i].outputs.servicePlanId
    runtime: app.customProperties.?runtime
    netFrameworkVersion: app.customProperties.?netFrameworkVersion
    javaVersion: app.customProperties.?javaVersion
    pythonVersion: app.customProperties.?pythonVersion
    nodeVersion: app.customProperties.?nodeVersion
    phpVersion: app.customProperties.?phpVersion
  }

  dependsOn: [
    onebankServicePlans
  ]
}]

output resourceGroupId string = onebankRG.id
output linuxAppServiceId string = defaultLinuxAppService.outputs.appServiceId
output windowsAppServiceId string = defaultWindowsAppService.outputs.appServiceId
output linuxAppServiceUrl string = defaultLinuxAppService.outputs.appServiceUrl
output windowsAppServiceUrl string = defaultWindowsAppService.outputs.appServiceUrl
