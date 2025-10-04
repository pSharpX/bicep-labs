using 'main.bicep'

param resourceGroupName = 'rg-onebank-dev'
param linuxAppServiceName = 'web-linux-onebank-app-dev'
param windowsAppServiceName = 'web-windows-onebank-app-dev'
param linuxServicePlan = 'asp-linux-onebank-app-dev'
param windowsServicePlan = 'asp-windows-onebank-app-dev'
param sku = 'B1'

param location = 'westus3'

param environment = 'dev'
param applicationId = 'onebank'
param owner = 'Team_Dragons'
param provisioner = 'bicep'

param apps = [
  {
    appName: 'onebank-bookstore'
    appKind: 'app'
    appSettings: [
      { name: 'ENV', value: 'DEVELOPMENT'}
      { name: 'DATABASE_USER', value: 'admin'}
      { name: 'DATABASE_PASSWORD', value: 'admin'}
      { name: 'WEBSITES_PORT', value: '8000'}
    ]
    serverKind: 'app'
    skuName: 'B3'
    isLinux: false
    startupCommand: 'cd fastapi-bookstore && pip install -r requirements.txt && uvicorn books:app'
    healthCheckPath: '/'
    customProperties: {
      pythonVersion: '3.11'
    }
    sourceControl: {
      repoUrl: 'https://github.com/pSharpX/python-labs'
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
      { name: 'WEBSITES_PORT', value: '8000'}
    ]
    serverKind: 'app,linux'
    skuName: 'B3'
    isLinux: true
    startupCommand: 'cd fastapi-bookstore && pip install -r requirements.txt && uvicorn books:app'
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
