import { appConfigType, locationType, envType, provisionerType, storageAccountNameType } from 'types.bicep'

targetScope = 'subscription'

@minLength(3)
@maxLength(24)
@description('Can contains alpanumric characters and dash')
param resourceGroupName string
param location locationType

@description('This represents all apps to be provisioned. Must contain server information and app details')
param botApp appConfigType
@description('This represents all apps to be provisioned. Must contain server information and app details')
param agentApp appConfigType
@description('This represents all apps to be provisioned. Must contain server information and app details')
param mcpServerApp appConfigType

param storageAccountName storageAccountNameType
param containerName string
param provisioner provisionerType
param environment envType = 'dev'

@minLength(3)
@maxLength(20)
@description('It represents the owner of the application. Must contains alpanumric chararacters and dash')
param applicationId string

@minLength(3)
@maxLength(20)
@description('It represents the owner of the application. Must contains alpanumric chararacters and dash')
param owner string


var tags object = {
  application: applicationId
  environment: environment
  owner: owner
  provisioner: provisioner
}

resource defaultRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module defaultStorageAccount 'modules/storage.bicep' = {
  name: 'deployment-sa-${applicationId}-${environment}'
  scope: defaultRG
  params: {
    location: location
    resourceName: storageAccountName
    tags: tags
  }
}

module defaultContainer 'modules/container.bicep' = {
  name: 'deployment-sa-container-${applicationId}-${environment}'
  scope: defaultRG
  params: {
    containerName: containerName
    storageAccountName: defaultStorageAccount.outputs.storageAccountName
  }
}

module botServicePlan 'modules/serviceplan.bicep' = {
  name: 'deployment-asp-${botApp.appName}-${environment}'
  scope: defaultRG
  params: {
    location: location
    resourceName: 'asp-${botApp.appName}-${environment}'
    skuName: botApp.skuName
    kind: botApp.serverKind
    tags:tags
  }
}

module botAppService 'modules/appservice.bicep' = {
  name: 'deployment-web-${botApp.appName}-${environment}'
  scope:defaultRG
  params: {
    location: location
    appName: 'web-${botApp.appName}-${environment}'
    repoUrl: botApp.?sourceControl.?repoUrl
    branch: botApp.?sourceControl.?branch
    startupCommand: botApp.?startupCommand
    healthCheckPath: botApp.?healthCheckPath
    kind: botApp.appKind
    appSettings: botApp.appSettings
    servicePlanId: botServicePlan.outputs.servicePlanId
    runtime: botApp.customProperties.?runtime
  }
}

module agentServicePlan 'modules/serviceplan.bicep' = {
  name: 'deployment-asp-${agentApp.appName}-${environment}'
  scope: defaultRG
  params: {
    location: location
    resourceName: 'asp-${agentApp.appName}-${environment}'
    skuName: agentApp.skuName
    kind: agentApp.serverKind
    tags:tags
  }
}

module agentAppService 'modules/appservice.bicep' = {
  name: 'deployment-web-${agentApp.appName}-${environment}'
  scope:defaultRG
  params: {
    location: location
    appName: 'web-${agentApp.appName}-${environment}'
    repoUrl: agentApp.?sourceControl.?repoUrl
    branch: agentApp.?sourceControl.?branch
    startupCommand: agentApp.?startupCommand
    healthCheckPath: agentApp.?healthCheckPath
    kind: agentApp.appKind
    appSettings: agentApp.appSettings
    servicePlanId: agentServicePlan.outputs.servicePlanId
    runtime: agentApp.customProperties.?runtime
  }
}

module mcpServerServicePlan 'modules/serviceplan.bicep' = {
  name: 'deployment-asp-${mcpServerApp.appName}-${environment}'
  scope: defaultRG
  params: {
    location: location
    resourceName: 'asp-${mcpServerApp.appName}-${environment}'
    skuName: mcpServerApp.skuName
    kind: mcpServerApp.serverKind
    tags:tags
  }
}

module mcpServerAppService 'modules/appservice.bicep' = {
  name: 'deployment-web-${mcpServerApp.appName}-${environment}'
  scope:defaultRG
  params: {
    location: location
    appName: 'web-${mcpServerApp.appName}-${environment}'
    repoUrl: mcpServerApp.?sourceControl.?repoUrl
    branch: mcpServerApp.?sourceControl.?branch
    startupCommand: mcpServerApp.?startupCommand
    healthCheckPath: mcpServerApp.?healthCheckPath
    kind: mcpServerApp.appKind
    appSettings: mcpServerApp.appSettings
    servicePlanId: mcpServerServicePlan.outputs.servicePlanId
    runtime: mcpServerApp.customProperties.?runtime
  }
}


output resourceGroupId string = defaultRG.id
output storageEndpoint string = defaultStorageAccount.outputs.blobEndpoint
output botUrl string = botAppService.outputs.appServiceUrl
output agentUrl string = agentAppService.outputs.appServiceUrl
output mcpServerUrl string = mcpServerAppService.outputs.appServiceUrl
