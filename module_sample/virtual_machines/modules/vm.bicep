
@description('Location for all resources')
param location string = resourceGroup().location
@description('Additional metadata')
param tags object

@minLength(3)
@maxLength(24)
@description('The name of the virtual machine')
param vmName string

@minLength(3)
@description('Username for the virtual machine')
param adminUserName string

@allowed([
  'sshPublicKey'
  'password'
])
@description('Type of authentication to use on the virtual machine. SSH is recommended')
param authenticationType string

@description('SSH Key or password for the virtual machine. SSH is recommended')
@secure()
param adminPasswordOrKey string

@allowed([
  'Ubuntu-1804'
  'Ubuntu-2004'
  'Ubuntu-2204'
])
param ubuntuOSImageVersion string

@allowed([
  'Standard_B2s'
  'Standard_B2ms'
  'Standard_D2_v2'
  'Standard_D2s_v3'
  'Standard_DS2'
])
@description('The size of the virtual machine')
param vmSize string = 'Standard_D2s_v3'

@allowed([
  'Standard'
  'TrustedLaunch'
])
@description('Security type of the virtual machine')
param securityType string = 'TrustedLaunch'

@description('Subnet ID')
param subNetId string

@description('Public IP Address ID')
param publicIPAddressId string

@description('Security Group Identifier')
param networkSecurityGroupId string

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

var networkInterfaceName = '${vmName}NetInt'
var osDiskType = 'Standard_LRS'

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUserName}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}


resource networkInterface 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: networkInterfaceName
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subNetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddressId
          }
        }
      }
    ]

    networkSecurityGroup: {
      id: networkSecurityGroupId
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
      imageReference: imageReference[ubuntuOSImageVersion]
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
      adminUsername: adminUserName
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }

    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
}

output adminUserName string = adminUserName

