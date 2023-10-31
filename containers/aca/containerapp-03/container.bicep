@description('Region in Azure where resources will be deploy')
param location string = resourceGroup().location

@description('Application Identifier')
@minLength(3)
@maxLength(8)
param applicationId string
@description('Application owner for Technical Support')
param owner string
@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string
@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string

param containerAppEnvId string
param registryLoginServer string
@secure()
param registryUsername string
@secure()
param registryPass string

@description('Specifies the name of the container app. Lowercase letters, numbers, and hyphens are allowed.')
@minLength(2)
@maxLength(32)
param containerAppName string = '${applicationId}-${uniqueString(resourceGroup().id)}-app'

@description('Specifies the docker container image to deploy.')
param containerImage string

@description('Specifies the docker container name')
param containerName string

@minValue(0)
@maxValue(25)
@description('Minimum number of replicas that will be deployed')
param minReplicas int = 1

@minValue(0)
@maxValue(25)
@description('Maximum number of replicas that will be deployed')
param maxReplicas int = 3

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvId
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      secrets: [
        {
          name: 'containerregistrypasswordref'
          value: registryPass
        }
      ]
      registries: [
        {
          server: registryLoginServer
          username: registryUsername
          passwordSecretRef: 'containerregistrypasswordref'
        }
      ]
    }
    template: {
      revisionSuffix: applicationId
      containers: [
        {
          image: containerImage
          name: containerName
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'      
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: [
          {
            name: 'http-request'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

output id string = containerApp.id
output endpoint string = containerApp.properties.configuration.ingress.fqdn
