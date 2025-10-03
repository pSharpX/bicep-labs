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
    appKind: 'app,linux'
    appSettings: [{name: 'ENV', value: 'DEVELOPMENT'}]
    serverKind: 'app,linux'
    skuName: sku
    isLinux: true
    customProperties: {
      runtime: 'TOMCAT|10.1-java21'
    }
  }
  {
    appName: 'onebank-bookstore'
    appKind: 'app,linux'
    appSettings: [
      { name: 'ENV', value: 'DEVELOPMENT'}
      { name: 'SCM_DO_BUILD_DURING_DEPLOYMENT', value: 'true' }
      { name: 'DATABASE_USER', value: 'admin'}
      { name: 'DATABASE_PASSWORD', value: 'admin'}
    ]
    serverKind: 'app,linux'
    skuName: sku
    isLinux: true
    startupCommand: 'cd fastapi-bookstore && pip install -r requirements.txt && uvicorn books:app --port=3000'
    customProperties: {
      runtime: 'PYTHON|3.12'
    }
    sourceControl: {
      repoUrl: 'https://github.com/pSharpX/python-labs.git'
      branch: 'main'
    }
  }
]
