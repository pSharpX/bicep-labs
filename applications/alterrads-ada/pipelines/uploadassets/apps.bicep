import { deploymentConfigType, locationType, envType, provisionerType, storageAccountNameType } from '../../types.bicep'

targetScope = 'subscription'

@minLength(3)
@maxLength(24)
@description('Can contains alpanumric characters and dash')
param resourceGroupName string
param location locationType


@description('The deployment configuration for scripts execution tasks')
param uploadAssetsDeploymentConfig deploymentConfigType

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

var fileName = 'criterios_cobertura.json'

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

resource defaultContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' existing = {
  scope: defaultRG
  name: '${storageAccountName}/default/${containerName}'
}

module uploadAssetsDeploymentScript '../../modules/deploymentscript.bicep' = {
  scope: defaultRG
  params: {
    location: location
    deploymentScriptName: uploadAssetsDeploymentConfig.deploymentName
    scriptContent: 'echo "$CONTENT" > ${fileName} && az storage blob upload -f ${fileName} -c ${containerName} -n ${fileName}'
    deploymentConfigs: union(uploadAssetsDeploymentConfig.appSettings, [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: defaultStorageAccount.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        value: defaultStorageAccount.listKeys().keys[0].value
      }
    ])
    kind: uploadAssetsDeploymentConfig.kind
    tags: tags
  }

  dependsOn: [
    defaultContainer
  ]
}


output resourceGroupId string = defaultRG.id
