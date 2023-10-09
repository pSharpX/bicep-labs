param location string = resourceGroup().location
param provisioner string
param owner string
param applicationId string
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string
@minValue(1)
@maxValue(3)
@description('Number of Virtual Machines to be created')
param vmCount int
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
  'Ubuntu-2204'
])
param imageVersion string
@minLength(3)
@description('Admin user of the Virtual Machine')
param adminUser string
@secure()
@description('SSH key for passwordless authentication')
param sshKey string


var imageReference = {
  'Ubuntu-1804': {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '18_04-lts-gen2'
    version: 'latest'
  }
  'Ubuntu-2204': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-jammy'
    sku: '22_04-lts-gen2'
    version: 'latest'
  }
}

@minLength(3)
param securityGroupName string
@minLength(3)
param virtualNetworkName string
@minLength(3)
param defaultSubnetName string
@minLength(3)
param dnsLabelPrefix string

var configurations = [for index in range(0, vmCount): {
  vMachineName: '${applicationId}_${uniqueString(resourceGroup().id, string(index))}_vm'
  hostname: '${applicationId}Machine${string(index)}'
  sshPublicKeyName: '${applicationId}_${uniqueString(resourceGroup().id, string(index))}_pk'
  publicIpName: '${applicationId}_${uniqueString(resourceGroup().id, string(index))}_pip'
  domainNameLabel: '${dnsLabelPrefix}${uniqueString(resourceGroup().id, string(index))}'
  nicName: '${applicationId}_${uniqueString(resourceGroup().id, string(index))}_nic'
}]

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2021-05-01' = [for (config, i) in configurations: {
  name: config.nicName
  location: location
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }

  properties: {
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', securityGroupName)
    }

    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, defaultSubnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${config.publicIpName}')
          }
        }
      }
    ]
  }

  dependsOn: [
    pips
  ]
}]

resource pips 'Microsoft.Network/publicIPAddresses@2021-05-01' = [for config in configurations: {
  name: config.publicIpName
  location: location
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: config.domainNameLabel
    }
    idleTimeoutInMinutes: 4
  }
}]

resource sshPublicKey 'Microsoft.Compute/sshPublicKeys@2023-07-01' = [for config in configurations: {
  name: config.sshPublicKeyName
  location: location
  tags: {
    applicationId: applicationId
    owner: owner
    environment: environment
    provisioner: provisioner
  }

  properties: {
    publicKey: sshKey
  }
}]

resource virtualMachines 'Microsoft.Compute/virtualMachines@2023-07-01' = [for (config, i) in configurations: {
  name: config.vMachineName
  location: location
  tags: {
    applicationId: applicationId
    owner: owner
    environment: environment
    provisioner: provisioner
  }

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    osProfile: {
      computerName: config.hostname
      adminUsername: adminUser
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUser}/.ssh/authorized_keys'
              keyData: sshPublicKey[i].properties.publicKey
            }
          ]
        }
      }
    }

    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }

      imageReference: imageReference[imageVersion]
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces[i].id
        }
      ]
    }
  }

  dependsOn: [
    networkInterfaces[i]
  ]
}]

output vMachines array = [for config in configurations: config.vMachineName]
output nics array = [for config in configurations: config.nicName]
output pIpAddresses array = [for config in configurations: config.publicIpName]
output fqdns array = [for (config, i) in configurations: pips[i].properties.dnsSettings.fqdn]
