@description('Region where resource will be created')
param location string = toLower(resourceGroup().location)

@description('Application Identifier')
@minLength(3)
@maxLength(15)
param applicationId string = 'seniorfitness'
@description('Application owner for Technical Support')
param owner string = 'aforo255'
@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string = 'dev'
@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string = 'bicep'

targetScope = 'resourceGroup'

module storage 'modules/storage.bicep' = {
  name: 'storageModule'
  params: {
    location: location
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }
}

module servicePlan 'modules/serviceplan.bicep' = {
  name: 'servicePlan'
  params: {
    location:location
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }
}

/*module webApp 'modules/webapp.bicep' = {
  name: 'webApp'
  params: {
    location: location
    servicePlanId: servicePlan.outputs.servicePlanId
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }
}*/

module nginxWebApp 'modules/nginx.bicep' = {
  name: 'nginxWebApp'
  params: {
    location: location
    servicePlanId: servicePlan.outputs.servicePlanId
    applicationId: applicationId
    owner: owner
    provisioner: provisioner
    environment: environment
  }
}
