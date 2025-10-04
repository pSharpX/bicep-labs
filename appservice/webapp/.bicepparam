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
