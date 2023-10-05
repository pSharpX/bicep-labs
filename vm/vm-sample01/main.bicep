param location string = resourceGroup().location

/** Metadata for resources */
param provisioner string
@minLength(3)
@description('Owner or contact for technical support')
param owner string
@minLength(3)
param applicationId string
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string

var tags = {
  applicationId: applicationId
  owner: owner
  provisioner: provisioner
  environment: environment
}

/** Virtual Machine required params */
@minLength(3)
@description('Name for the Virtual Machine')
param vmName string
@description('Size for the Virtual Machine')
@allowed([
  'Standard_B2s'
  'Standard_B2ms'
  'Standard_D2_v2'
  'Standard_D2s_v3'
  'Standard_DS2'
])
param vmSize string
@description('Image Version for the Virtual Machine')
@allowed([
  'Ubuntu-1804'
  'Ubuntu-2004'
  'Ubuntu-2204'
])
param imageVersion string
@description('Admin user of the Virtual Machine')
@minLength(3)
param adminUser string
@description('SSH key for passwordless authentication')
@secure()
param sshKey string
param osDiskType string = 'Standard_LRS'
@description('Custom Data for provisioning Virtual Machine on first boot')
param customData string

var imageReference = {
  'Ubuntu-1804': {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '18_04-lts-gen2'
    version: 'latest'
  }
  'Ubuntu-2004': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts-gen2'
    version: 'latest'
  }
  'Ubuntu-2204': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-jammy'
    sku: '22_04-lts-gen2'
    version: 'latest'
  }
}

/** Security Group required params */
@description('Security Group name for Inbound/Outbound traffic rules configuration')
param securityGroupName string

@description('Inbound Rules for security Group')
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

/** Public IP Address required params */
@minLength(3)
param publicIpAddressName string
@minLength(3)
param dnsLabelPrefix string

/** Virtual Network required params */
@description('Virtual Network name for the Virtual Machine')
@minLength(3)
param vNetName string
@description('Name of the subnet in the virtual network')
@minLength(3)
param subnetName string
param addressPrefix string = '10.1.0.0/16'
param subnetAddressPrefix string = '10.1.0.0/24'

/** Network Interface required params */
param networkInterfaceName string


resource securityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: securityGroupName
  location: location
  tags: tags

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

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpAddressName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }

  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }

    idleTimeoutInMinutes: 4
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vNetName
  location: location
  tags: tags

  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: networkInterfaceName
  location: location
  tags: tags

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]

    networkSecurityGroup: {
      id: securityGroup.id
    }
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  tags: tags

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: imageReference[imageVersion]
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUser
      adminPassword: sshKey
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUser}/.ssh/authorized_keys'
              keyData: sshKey
            }
          ]
        }
      }
      customData: !empty(customData) ? customData: null
    }

    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
  }
}

output adminUser string = adminUser
output hostname string = publicIpAddress.properties.dnsSettings.fqdn
output sshCommand string = 'ssh -i <private_key_path> ${adminUser}@${publicIpAddress.properties.dnsSettings.fqdn}'
