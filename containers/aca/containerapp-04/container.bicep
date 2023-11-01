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

@minLength(5)
@maxLength(50)
@description('Specifies the name of the App Configuration store. Alphanumerics, underscores, and hyphens are allowed.')
param configStoreName string

param storageName string

@description('Allows read access to App Configuration data.')
var roleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

resource configStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: configStoreName
  
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
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
          env: [
            {
              name: 'AZURE_APPCONFIGURATION_ENDPOINT'
              value: configStore.properties.endpoint
            }
          ]
          volumeMounts: [
            {
              volumeName: 'configmount'
              mountPath: '/var/log/nginx'
            }
          ]
        }
      ]
      volumes: [
        {
          name: 'configmount'
          storageType: 'AzureFile'
          storageName: storageName
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

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(configStore.id, roleDefinitionId, containerApp.id)
  scope: configStore
  properties: {
    principalId: containerApp.identity.principalId
    roleDefinitionId: roleDefinitionId
    principalType: 'ServicePrincipal'
  }
}

output id string = containerApp.id
output endpoint string = containerApp.properties.configuration.ingress.fqdn
