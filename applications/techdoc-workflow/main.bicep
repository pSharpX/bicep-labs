
@minLength(3)
@maxLength(24)
@description('Can contains alpanumric characters and dash')
param resourceGroupName string

@description('Region where resource will be created')
param location string

@description('Application Identifier')
@minLength(3)
@maxLength(15)
param applicationId string = 'techdoc'
@description('Application owner for Technical Support')
param owner string = 'Team_UTECT'
@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string = 'dev'
@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string = 'bicep'

@description('TechDoc UI Docker image name to be deployed in web app')
param techdocUIAppImage string

targetScope = 'subscription'

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

module servicePlan 'modules/serviceplan.bicep' = {
  name: 'servicePlan'
  scope: defaultRG
  params: {
    location:location
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }
}

module techdocUI 'modules/appservice.bicep' = {
  name: 'techdocUI'
  scope: defaultRG
  params: {
    location: location
    servicePlanId: servicePlan.outputs.servicePlanId
    dockerImage: techdocUIAppImage
    dockerImageTag: 'latest'
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }
}
