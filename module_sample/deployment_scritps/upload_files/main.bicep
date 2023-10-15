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

@minLength(3)
param storageAccountName string
@minLength(3)
param storageAccountResourceGroup string
@minLength(3)
param containerName string

@description('List of objects containing fileNames and content to be uploaded to Blob Service')
@minLength(1)
param files array

module deploymentScript 'modules/deployment_script.bicep' = [for item in files: if (item.upload) {
  name: 'uploadfile-${uniqueString(resourceGroup().id, item.fileName)}'
  params: {
    deploymentScriptName: 'uploadfile_${uniqueString(resourceGroup().id, item.fileName)}_ds'
    applicationId: applicationId
    owner: owner
    environment: environment
    provisioner: provisioner
    storageAccountName: storageAccountName
    containerName: containerName
    storageAccountResourceGroup: storageAccountResourceGroup
    location: location
    fileName: item.fileName
    fileContent: item.fileContent
  }
}]

output signedFileURI array = [for (item, i) in files: (item.upload) ? deploymentScript[i].outputs.signedFileURI : 'ALREADY_UPLOADED']
