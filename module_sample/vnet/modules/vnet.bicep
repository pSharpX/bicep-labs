
@minLength(3)
param location string = resourceGroup().location

param vNetName string
param owner string
param applicationId string
@allowed(['dev', 'test', 'prod'])
param environment string
@allowed(['terraform', 'arm', 'bicep', 'crossplane'])
param provisioner string
param addressPrefix string = '10.1.0.0/16'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vNetName
  location: location
  tags: {
    owner: owner
    applicationI: applicationId
    environment: environment
    provisioner: provisioner
  }

  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
}

output virtualNetworkId string = virtualNetwork.id
output virtualNetworkName string = virtualNetwork.name
