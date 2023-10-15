@minLength(3)
@description('Specifies the location in which the Azure Storage resources should be deployed.')
param location string = resourceGroup().location

@minLength(3)
@maxLength(15)
param applicationId string

@description('Application owner for Technical Support')
param owner string

@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string

@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string

@minLength(2)
@maxLength(8)
@description('Represents the Prefix name to be used for naming all Azure Resources. Must be valid string')
param resourceNamePrefix string

@description('Name of the blob as it is stored in the blob container')
param fileName string
@description('Content of the blob as it is stored in the blob container')
param fileContent string
param baseTime string = utcNow('u')

var storageAccountName = '${resourceNamePrefix}${uniqueString(resourceGroup().id, environment)}sa'
var containerName = 'installation-scripts'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  tags: {
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }

  sku: {
    name: 'Standard_LRS'  
  }

  properties: {
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: containerName
  parent: blobService
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'uploadDockerInstallationScript'
  kind: 'AzureCLI'
  location: location
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storageAccount.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        value: storageAccount.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: fileContent
      }
    ]

    scriptContent: 'echo "$CONTENT" > ${fileName} && az storage blob upload -f ${fileName} -c ${container.name} -n ${fileName}'
  }
  tags: {
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }
}

var add1Hour = dateTimeAdd(baseTime, 'PT1H')
var serviceSASConfig = {
  canonicalizedResource: '/blob/${storageAccount.name}/${container.name}/${fileName}'
  signedExpiry: add1Hour
  signedPermission: 'rl'
  signedResource: 'b'
  signedProtocol: 'https'
}

var serviceSASToken = storageAccount.listServiceSAS('2023-01-01', serviceSASConfig).serviceSasToken

output storageAccountId string = storageAccount.id
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output containerId string = container.id
output fileServiceSasToken string = serviceSASToken
output fileUrl string = '${storageAccount.properties.primaryEndpoints.blob}${container.name}/${fileName}?${serviceSASToken}'
