
@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the Virtual Network')
param virtualNetworkName string
@description('Name of the subnet in the virtual network')
param subnetName string

var subnetAddressPrefix = '10.1.0.0/24'
var addressPrefix = '10.1.0.0/16'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: virtualNetworkName
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: virtualNetwork
  name: subnetName

  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output virtualNetworkId string = virtualNetwork.id
output virtualNetworkName string = virtualNetwork.name
output subnetId string = subnet.id
output subnetName string = subnet.name
