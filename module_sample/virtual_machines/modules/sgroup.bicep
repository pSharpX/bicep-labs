
@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the security group')
param networkSecurityGroupName string = 'SecGroupName'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: networkSecurityGroupName
  location: location

  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

output securityGroupId string = networkSecurityGroup.id
