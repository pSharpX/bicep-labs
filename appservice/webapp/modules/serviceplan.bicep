
@minLength(3)
param location string = resourceGroup().location
param tags object = {}

@minLength(1)
@maxLength(34)
@description('Must be 1–40 chars, only letters/numbers/hyphen, cannot start/end with hyphen.')
param resourceName string

//https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md#app-service-resource-kind-reference
@allowed([
  'app'                                     // Windows Web app
  'app,linux'                               // Linux Web app
  'app,linux,container'                     // Linux Container Web app
  'hyperV'                                  // Windows Container Web App
  'app,container,windows'                   // Windows Container Web App
  'app,linux,kubernetes'                    // Linux Web App on ARC
  'app,linux,container,kubernetes'          // Linux Container Web App on ARC
  'functionapp'                             // Function Code App
  'functionapp,linux'                       // Linux Consumption Function app
  'functionapp,linux,container,kubernetes'  // Function Container App on ARC
  'functionapp,linux,kubernetes'            // Function Code App on ARC
])
param kind string = 'app'

@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'I1'
  'I2'
  'I3'
  'P1v2'
  'P2v2'
  'P3v2'
  'PC1'
  'PC2'
  'PC3'
  'PC4'
  'EP1'
  'EP2'
  'EP3'
  'EI1'
  'EI2'
  'EI3'
  'U1'
  'U2'
  'U3'
  'Y1'
])
@description('The list of SKUs that can be specified for App Services Plan.')
param skuName string = 'B2'

resource defaultServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name:resourceName
  location:location
  kind:kind
  sku:{
    name:skuName
  }
  properties:{
    reserved: contains(kind, 'linux') ? true: false
  }
  tags:tags
}

output servicePlanId string = defaultServicePlan.id
