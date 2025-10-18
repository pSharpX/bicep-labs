import { locationType, deploymentScriptKindType , appSettingType } from '../types.bicep'

param location locationType
param tags object = {}

@minLength(1)
@maxLength(90)
@description('The resource name')
param deploymentScriptName string

param kind deploymentScriptKindType = 'AzureCLI'
param deploymentConfigs appSettingType[] = []
param timeout string = 'PT5M'
param rententionInterval string = 'PT1H'

@description('Command or script to be executed')
param scriptContent string
@description('Command line arguments to pass to the script. Arguments are separated by spaces. ex: -Name blue* -Location \'West US 2\'')
param arguments string = ''
@description('Managed Identity attached to the Deployment Script container')
param managedIdentities object = {}


resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptName
  kind:  'AzureCLI'
  location: location
  properties: {
    azCliVersion: '2.48.1'
    timeout: timeout
    retentionInterval: rententionInterval
    cleanupPreference: 'Always'
    environmentVariables: deploymentConfigs
    scriptContent: scriptContent
    ...(!empty(arguments) ? { arguments: arguments }: {})
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
