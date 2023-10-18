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

@description('Specifies the name of the log analytics workspace.')
@minLength(4)
@maxLength(63)
param logWorkspaceName string = '${applicationId}-${uniqueString(resourceGroup().id)}-logws'

@description('Specifies the name of the container app environment.')
@minLength(2)
@maxLength(32)
param containerAppEnvName string = '${applicationId}-${uniqueString(resourceGroup().id)}-env'


@description('Specifies the name of the container app.')
@minLength(2)
@maxLength(32)
param containerAppName string = '${applicationId}-${uniqueString(resourceGroup().id)}-app'

// Since this image is public we don’t need to specify any registries, this will also pull from DockerHub automatically.
@description('Specifies the docker container image to deploy.')
param containerImage string = 'nginx:latest' 

@description('Specifies the docker container name')
param containerName string = 'nginx-app'

@minValue(0)
@maxValue(25)
@description('Minimum number of replicas that will be deployed')
param minReplicas int = 1

@minValue(0)
@maxValue(25)
@description('Maximum number of replicas that will be deployed')
param maxReplicas int = 3

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logWorkspaceName
  location: location

  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name:  containerAppEnvName
  location: location
  
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    vnetConfiguration: {
      internal: false
    }    
  }
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

resource sfitContainerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location

  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
      }
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


output containerAppId string = sfitContainerApp.id
output containerAppName string = sfitContainerApp.name
output fqdn string = sfitContainerApp.properties.configuration.ingress.fqdn
