import { deploymentConfigType, locationType, envType, provisionerType, storageAccountNameType } from '../../types.bicep'

targetScope = 'subscription'

@minLength(3)
@maxLength(24)
@description('Can contains alpanumric characters and dash')
param resourceGroupName string
param location locationType


@description('The deployment configuration for scripts execution tasks')
param botDeploymentConfig deploymentConfigType

param appServiceName string
param storageAccountName storageAccountNameType
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

resource defaultRG 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: resourceGroupName
}

resource defaultStorageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  scope: defaultRG
  name: storageAccountName
}

resource defaultAppService 'Microsoft.Web/sites@2024-11-01' existing = {
  scope: defaultRG
  name: appServiceName
}

var botScriptContent = '''
git clone $GITHUB_REPOSITORY_URL
cd ada-bot
zip -r app.zip . -x '.*'
az webapp deploy --name $APP_SERVICE_NAME --resource-group $RESOURCE_GROUP_NAME --src-path app.zip
'''

module botDeploymentScript '../../modules/deploymentscript.bicep' = {
  scope: defaultRG
  params: {
    location: location
    deploymentScriptName: botDeploymentConfig.deploymentName
    scriptContent: botScriptContent
    deploymentConfigs: union(botDeploymentConfig.appSettings, [
      {
        name: 'RESOURCE_GROUP_NAME'
        value: defaultRG.name
      }
      {
        name: 'APP_SERVICE_NAME'
        value: defaultAppService.name
      }
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: defaultStorageAccount.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        value: defaultStorageAccount.listKeys().keys[0].value
      }
    ])
    kind: botDeploymentConfig.kind
    tags: tags
  }
}


output resourceGroupId string = defaultRG.id
