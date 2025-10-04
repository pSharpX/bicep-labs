
import { appConfigListType, locationType } from 'types.bicep'

targetScope = 'subscription'

@minLength(3)
@maxLength(24)
@description('Can contains alpanumric characters and dash')
param resourceGroupName string

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
    healthCheckPath: app.?healthCheckPath
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
output appServicesIds array = [for (_, i) in apps: onebankAppServices[i].outputs.appServiceId]
output appServicesUrls array = [for (_, i) in apps: onebankAppServices[i].outputs.appServiceUrl]
