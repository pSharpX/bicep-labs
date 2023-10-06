
@minLength(1)
param virtualNetworkId string
@minLength(1)
param virtualNetworkName string
@minLength(3)
param subnetName string
param subnetAddressPrefix string = '10.1.0.0/24'

resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${virtualNetworkName}/${subnetName}'

  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output defaultSubnetId string = defaultSubnet.id
