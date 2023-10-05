param location string = resourceGroup().location

/** Metadata for resources */
param provisioner string
param owner string
param applicationId string
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string

var tags = {
  applicationId: applicationId
  owner: owner
  environment: environment
  provisioner: provisioner
}

/** Virtual Machine required params */
@minLength(3)
@description('Name for the Virtual Machine')
param vmName string
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
//@description('Custom Data for provisioning Virtual Machine on first boot')
//param customData string

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

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-05-01' existing = {
  name: networkInterfaceName
}

resource sshPublicKey 'Microsoft.Compute/sshPublicKeys@2023-07-01' = {
  name: '${vmName}PublicKey'
  location: location
  tags: tags

  properties: {
    publicKey: sshKey
  }
}

resource virtualMachines 'Microsoft.Compute/virtualMachines@2023-07-01' = [for vm in range(1, vmCount): {
  name: uniqueString(resourceGroup().id, string(vm))
  location: location
  tags: tags

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    osProfile: {
      computerName: '${vmName}${string(vm)}'
      adminUsername: adminUser
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUser}/.ssh/authorized_keys'
              keyData: sshPublicKey.properties.publicKey
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
          id: networkInterface.id
        }
      ]
    }
  }
}]
