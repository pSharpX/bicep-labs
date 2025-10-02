using 'main.bicep'

param resourceGroupName = 'rg-onebank-dev'
param linuxAppServiceName = 'web-linux-onebank-app-dev'
param windowsAppServiceName = 'web-windows-onebank-app-dev'
param linuxServicePlan = 'asp-linux-onebank-app-dev'
param windowsServicePlan = 'asp-windows-onebank-app-dev'

param location = 'centralus'

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
    skuName: 'F1'
    isLinux: true
    customProperties: {
      runtime: 'DOTNETCORE|8.0'
    }
  }
  {
    appName: 'onebank-bookstore'
    appKind: 'app,linux'
    appSettings: [{name: 'ENV', value: 'DEVELOPMENT'}]
    serverKind: 'app,linux'
    skuName: 'F1'
    isLinux: true
    customProperties: {
      runtime: 'JAVA|8-jre8'
    }
  }
  {
    appName: 'onebank-bookstore'
    appKind: 'app,linux'
    appSettings: [{name: 'ENV', value: 'DEVELOPMENT'}]
    serverKind: 'app,linux'
    skuName: 'F1'
    isLinux: true
    customProperties: {
      runtime: 'PHP|8.2'
    }
  }
]
