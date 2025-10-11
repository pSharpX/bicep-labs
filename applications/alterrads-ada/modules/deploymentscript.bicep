import { locationType, deploymentScriptKindType , appSettingType } from '../types.bicep'

param location locationType
param tags object = {}

@minLength(1)
@maxLength(90)
@description('The resource name')
param deploymentScriptName string

param kind deploymentScriptKindType = 'AzureCLI'
param deploymentConfigs appSettingType[] = []

@description('Command or script to be executed')
param scriptContent string
@description('Managed Identity attached to the Deployment Script container')
param managedIdentities object = {}


resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptName
  kind:  'AzureCLI'
  location: location
  properties: {
    azCliVersion: '2.48.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: deploymentConfigs
    scriptContent: scriptContent
    cleanupPreference: 'Always'
  }
  tags: tags
  identity: (!empty(managedIdentities) ? {
      type: 'UserAssigned'
      userAssignedIdentities: managedIdentities
    }: null)
}

output deploymentScriptId string = deploymentScript.id
output outputText string = deploymentScript.properties.outputs.text
output status object = deploymentScript.properties.status
