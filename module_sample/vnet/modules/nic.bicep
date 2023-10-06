@minLength(3)
param location string = resourceGroup().id
@minLength(3)
param nicName string
param owner string
param applicationId string
@allowed(['dev', 'test', 'prod'])
param environment string
@allowed(['terraform', 'arm', 'bicep', 'crossplane'])
param provisioner string
@minLength(3)
param securityGroupId string
@minLength(3)
param publicIpAddressId string
@minLength(3)
param defaultSubnetId string

resource defaultNetworkInterface 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }

  properties: {
    networkSecurityGroup: {
      id: securityGroupId
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: defaultSubnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddressId
          }
        }
      }
    ]
  }
}

output networkInterfaceId string = defaultNetworkInterface.id
