using 'apps.bicep'

param resourceGroupName = 'rg-onebank-dev'
param location = 'westus3'

param environment = 'dev'
param applicationId = 'onebank'
param owner = 'Team_Dragons'
param provisioner = 'bicep'

param apps = [
  {
    appName: 'onebank-bookstore'
    appKind: 'app,linux'
    appSettings: [
      { name: 'SPRING_PROFILES_ACTIVE', value: 'dev'}
      { name: 'CONTROL_PLANE_DATABASE_ENABLED', value: 'false'}
      { name: 'CONTROL_PLANE_CACHE_ENABLED', value: 'false'}
      { name: 'CONTROL_PLANE_NOTIFICATION_ENABLED', value: 'false'}
      { name: 'MANAGEMENT_HEALTH_REDIS_ENABLED', value: 'false'}
      { name: 'WEBSITES_PORT', value: '8080'}
    ]
    serverKind: 'app,linux'
    skuName: 'B3'
    isLinux: true
    startupCommand: 'cd controlplane && ./gradlew build && ./gradlew bootRun'
    customProperties: {
      runtime: 'JAVA|17-java17'
    }
    sourceControl: {
      repoUrl: 'https://github.com/pSharpX/monorepo-commons'
      branch: 'main'
    }
  }
  {
    appName: 'onebank-bookstore'
    appKind: 'app,linux'
    appSettings: [
      { name: 'ENV', value: 'DEVELOPMENT'}
      { name: 'DATABASE_USER', value: 'admin'}
      { name: 'DATABASE_PASSWORD', value: 'admin'}
      { name: 'WEBSITES_PORT', value: '3000'}
    ]
    serverKind: 'app,linux'
    skuName: 'B3'
    isLinux: true
    startupCommand: 'cd fastapi-bookstore && pip install -r requirements.txt && python books.py'
    healthCheckPath: '/'
    customProperties: {
      runtime: 'PYTHON|3.12'
    }
    sourceControl: {
      repoUrl: 'https://github.com/pSharpX/python-labs'
      branch: 'main'
    }
  }
]
