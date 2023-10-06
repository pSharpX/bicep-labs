
@minLength(3)
param location string = resourceGroup().location
@minLength(3)
param securityGroupName string
param owner string
param applicationId string
@allowed(['dev', 'test', 'prod'])
param environment string
@allowed(['terraform', 'arm', 'bicep', 'crossplane'])
param provisioner string
@minLength(1)
param securityRules array = [
  {
    name: 'Allow-SSH-All'
    priority: 100
    protocol: 'Tcp'
    access: 'Allow'
    direction: 'Inbound'
    destinationPortRange: '22'
  }
  {
    name: 'Allow-WEB-HTTPS'
    priority: 200
    protocol: 'Tcp'
    access: 'Allow'
    direction: 'Inbound'
    destinationPortRange: '443'
  }
  {
    name: 'Allow-WEB-HTTP'
    priority: 300
    protocol: 'Tcp'
    access: 'Allow'
    direction: 'Inbound'
    destinationPortRange: '80'
  }
]

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: securityGroupName
  location: location
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }

  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        priority: rule.priority
        protocol: rule.protocol
        access: rule.access
        direction: rule.direction
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: rule.destinationPortRange
      }
    }]
  }
}

output securityGroupId string = securityGroup.id
