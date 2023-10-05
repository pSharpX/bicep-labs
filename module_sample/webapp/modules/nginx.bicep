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

@description('ServicePlan identifier')
param servicePlanId string

@description('Docker image name to be deployed in web app')
param dockerImage string = 'nginx'
@description('Docker image tag to be deployed in web app')
param dockerImageTag string = 'latest'


resource nginxWebApp 'Microsoft.Web/sites@2022-09-01' = {
  name: resourceName
  location: location

  properties: {
    serverFarmId: servicePlanId
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVICE_URL'
          value: 'https://index.docker.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: ''
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: ''
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      linuxFxVersion: 'DOCKER|${dockerImage}:${dockerImageTag}'
    }
  }

  tags: {
    applicationId: applicationId
    owner: owner
    environment: environment
    provisioner: provisioner
  }
}

output siteUrl string = nginxWebApp.properties.hostNames[0]
