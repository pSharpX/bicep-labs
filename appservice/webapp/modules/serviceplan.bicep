import { servicePlanSkuType, servicePlanKindType } from '../types.bicep'

@minLength(3)
param location string = resourceGroup().location
param tags object = {}

@minLength(1)
@maxLength(34)
@description('Must be 1-40 chars, only letters/numbers/hyphen, cannot start/end with hyphen.')
param resourceName string
param kind servicePlanKindType = 'app'

@description('Instance size')
param skuName servicePlanSkuType = 'B2'

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
