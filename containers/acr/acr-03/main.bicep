@description('Region in Azure where resources will be deploy')
param location string = resourceGroup().location

@description('Application Identifier')
@minLength(3)
@maxLength(10)
param applicationId string
@description('Application owner for Technical Support')
param owner string
@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string
@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string

@description('Provide a globally unique name of your Azure Container Registry')
@minLength(5)
@maxLength(50)
param containerRegistryName string = '${applicationId}${uniqueString(resourceGroup().id)}acr'

param identityName string = '${applicationId}msi'

@description('Container images to be imported into the Container Registry')
@minLength(1)
@maxLength(10)
param containerImages array = [
  'docker.io/library/nginx:latest'
  'docker.io/library/alpine:latest'
  'docker.io/library/redis:latest'
  'docker.io/library/hello-world:latest'
]

var acrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
var acrImportRole = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor role is needed for import action

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, managedIdentity.id, acrImportRole)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: acrImportRole
    principalType: 'ServicePrincipal'
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

@description('This module seeds the ACR with the public version of the app')
module acrImportImage 'br/public:deployment-scripts/import-acr:3.0.2' = {
  name: 'importContainerImages'
  params: {
    acrName: containerRegistry.name
    location: location
    useExistingManagedIdentity: true
    managedIdentityName: managedIdentity.name
    existingManagedIdentitySubId: subscription().subscriptionId
    existingManagedIdentityResourceGroupName: resourceGroup().name
    images: containerImages
  }
  dependsOn: [
    acrRoleAssignment
  ]
}

output registryId string = containerRegistry.id
output loginServer string = containerRegistry.properties.loginServer
output importedImages array = acrImportImage.outputs.importedImages
