@description('Region where resource will be created')
param location string

@description('Application Identifier')
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
@description('Name of the resource. Must be valid name')
param resourceName string = toLower('${applicationId}sp${environment}')


resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: resourceName
  location: location
  kind: 'linux'
  sku: {
    name: 'F1'
  }

  properties: {
    reserved: true
  }

  tags: {
    applicationId: applicationId
    owner: owner
    environment: environment
    provisioner: provisioner
  }
}

output servicePlanId string = appServicePlan.id
