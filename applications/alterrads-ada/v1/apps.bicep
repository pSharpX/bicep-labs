import { appConfigType, locationType, envType, provisionerType, storageAccountNameType } from '../types.bicep'
import { storageBlobDataContributor } from '../roles.bicep'

targetScope = 'subscription'

@minLength(3)
@maxLength(24)
@description('Can contains alpanumric characters and dash')
param resourceGroupName string
param location locationType

param managedIdentityName string
param storageAccountName storageAccountNameType
param containerName string
param fileShareName string

@description('This represents all apps to be provisioned. Must contain server information and app details')
param botApp appConfigType
@description('This represents all apps to be provisioned. Must contain server information and app details')
param agentApp appConfigType
@description('This represents all apps to be provisioned. Must contain server information and app details')
param mcpServerApp appConfigType

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

module defaultStorageAccount '../modules/storage.bicep' = {
  name: 'deployment-sa-${applicationId}-${environment}'
  scope: defaultRG
  params: {
    location: location
    resourceName: storageAccountName
    enableBlobStorage: true
    enableFileShared: true
    tags: tags
  }
}

module defaultManagedIdentity '../modules/identity.bicep' = {
  name: 'deployment-identity-${applicationId}-${environment}'
  scope: defaultRG
  params: {
    location: location
    identityName: managedIdentityName
    storageScopeRoleAssignments: [
      {
        resourceName: defaultStorageAccount.outputs.storageAccountName
        roleId: storageBlobDataContributor
      }
    ]
    tags: tags
  }
  dependsOn: [
    defaultContainer
  ]
}

module defaultContainer '../modules/container.bicep' = {
  name: 'deployment-sa-container-${applicationId}-${environment}'
  scope: defaultRG
  params: {
    containerName: containerName
    storageAccountName: defaultStorageAccount.outputs.storageAccountName
  }
}

module defaultFileShare '../modules/fileshares.bicep' = {
  name: 'deployment-sa-fileshare-${applicationId}-${environment}'
  scope: defaultRG
  params: {
    shareName: fileShareName
    storageAccountName: defaultStorageAccount.outputs.storageAccountName
    shareQuota: 5
  }
}

module mcpServerServicePlan '../modules/serviceplan.bicep' = {
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

module mcpServerAppService '../modules/appservice.bicep' = {
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
    appSettings: botApp.appSettings
    servicePlanId: mcpServerServicePlan.outputs.servicePlanId
    runtime: mcpServerApp.customProperties.?runtime
  }
}

module agentServicePlan '../modules/serviceplan.bicep' = {
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

module agentAppService '../modules/appservice.bicep' = {
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
    appSettings: union([
      { name: 'MCP_INSURANCE_URL', value: '${mcpServerAppService.outputs.appServiceUrl}/insurance/mcp'}
      { name: 'MCP_MEDICATIONS_URL', value: '${mcpServerAppService.outputs.appServiceUrl}/medis/mcp'}
    ], botApp.appSettings)
    servicePlanId: agentServicePlan.outputs.servicePlanId
    runtime: agentApp.customProperties.?runtime
  }
}

module botServicePlan '../modules/serviceplan.bicep' = {
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

module botAppService '../modules/appservice.bicep' = {
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
    appSettings: union([
      { name: 'MCP_INSURANCE_URL', value: '${mcpServerAppService.outputs.appServiceUrl}/insurance/mcp'}
      { name: 'MCP_MEDICATIONS_URL', value: '${mcpServerAppService.outputs.appServiceUrl}/medis/mcp'}
      { name: 'VISION_AGENT_URL', value: agentAppService.outputs.appServiceUrl}
    ], botApp.appSettings)
    servicePlanId: botServicePlan.outputs.servicePlanId
    runtime: botApp.customProperties.?runtime
    managedIdentities: {
      '${defaultManagedIdentity.outputs.identityId}': {}
    }
  }
}


output resourceGroupId string = defaultRG.id
output storageEndpoint string = defaultStorageAccount.outputs.blobEndpoint
output mcpServerHostname string = mcpServerAppService.outputs.appServiceHostname
output agentUrlHostname string = agentAppService.outputs.appServiceHostname
output botUrlHostname string = botAppService.outputs.appServiceHostname
