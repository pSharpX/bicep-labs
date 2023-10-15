param location string = resourceGroup().location
param provisioner string
param owner string
param applicationId string
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string
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
@description('Represents the Network Security Group assign to the NiC')
param securityGroupName string
@minLength(3)
@description('Represents the Virtual Network where the VM will be assign to')
param virtualNetworkName string
@minLength(3)
@description('Represents the default subnet')
param defaultSubnetName string
@minLength(3)
@description('Represents the DNS prefix for the PublicIP Address ')
param dnsLabelPrefix string
@description('Storage account where Virtual Machines Provisioning Scripts are placed')
param storageAccountName string
@description('Resource group on which storage account is deployed')
param storageAccountResourceGroup string
@description('Represents the current date time in UTC format')
param baseTime string = utcNow('u')
var add1Hour = dateTimeAdd(baseTime, 'PT1H')

var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, defaultSubnetName)
var nsgRef = resourceId('Microsoft.Network/networkSecurityGroups', securityGroupName)

var configs = {
  webServer: {
    create: false
    vMachineName: '${applicationId}_${uniqueString(resourceGroup().id, 'webserver')}_vm'
    hostname: '${applicationId}WebServer'
    sshPublicKeyName: '${applicationId}_${uniqueString(resourceGroup().id, 'webserver')}_pk'
    publicIpName: '${applicationId}_${uniqueString(resourceGroup().id, 'webserver')}_pip'
    domainNameLabel: '${dnsLabelPrefix}${uniqueString(resourceGroup().id, 'webserver')}'
    nicName: '${applicationId}_${uniqueString(resourceGroup().id, 'webserver')}_nic'
    hasInstallationScript: false
  }
  backendServer: {
    create: true
    vMachineName: '${applicationId}_${uniqueString(resourceGroup().id, 'backendServer')}_vm'
    hostname: '${applicationId}BackendServer'
    sshPublicKeyName: '${applicationId}_${uniqueString(resourceGroup().id, 'backendServer')}_pk'
    publicIpName: '${applicationId}_${uniqueString(resourceGroup().id, 'backendServer')}_pip'
    domainNameLabel: '${dnsLabelPrefix}${uniqueString(resourceGroup().id, 'backendServer')}'
    nicName: '${applicationId}_${uniqueString(resourceGroup().id, 'backendServer')}_nic'
    hasInstallationScript: true
    fileName: 'install_docker.sh'
    commandToExecute: 'sh install_docker.sh'
  }
  dbServer: {
    create: false
    vMachineName: '${applicationId}_${uniqueString(resourceGroup().id, 'dbServer')}_vm'
    hostname: '${applicationId}DbServer'
    sshPublicKeyName: '${applicationId}_${uniqueString(resourceGroup().id, 'dbServer')}_pk'
    publicIpName: '${applicationId}_${uniqueString(resourceGroup().id, 'dbServer')}_pip'
    domainNameLabel: '${dnsLabelPrefix}${uniqueString(resourceGroup().id, 'dbServer')}'
    nicName: '${applicationId}_${uniqueString(resourceGroup().id, 'dbServer')}_nic'
    hasInstallationScript: false
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
  scope: resourceGroup(storageAccountResourceGroup)
}

resource pips 'Microsoft.Network/publicIPAddresses@2021-05-01' = [for server in items(configs): if (server.value.create) {
  name: server.value.publicIpName
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
      domainNameLabel: server.value.domainNameLabel
    }
    idleTimeoutInMinutes: 4
  }
}]

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2021-05-01' = [for (server, i) in items(configs): if (server.value.create) {
  name: server.value.nicName
  location: location
  tags: {
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }

  properties: {
    networkSecurityGroup: {
      id: nsgRef
    }

    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pips[i].id
          }
        }
      }
    ]
  }
}]

resource sshPublicKey 'Microsoft.Compute/sshPublicKeys@2023-07-01' = [for server in items(configs): if (server.value.create) {
  name: server.value.sshPublicKeyName
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

resource virtualMachines 'Microsoft.Compute/virtualMachines@2023-07-01' = [for (server, i) in items(configs): if (server.value.create) {
  name: server.value.vMachineName
  location: location
  tags: {
    applicationId: applicationId
    owner: owner
    environment: environment
    provisioner: provisioner
    role: server.key
  }

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    osProfile: {
      computerName: server.value.hostname
      adminUsername: adminUser
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
}]

var serviceSASConfig = {
  canonicalizedResource: '/blob/${storageAccount.name}/installation-scripts'
  signedExpiry: add1Hour
  signedPermission: 'r'
  signedResource: 'c'
  signedProtocol: 'https'
}
var serviceSASToken = storageAccount.listServiceSas('2023-01-01', serviceSASConfig).serviceSasToken
var installationScriptFolder = '${storageAccount.properties.primaryEndpoints.blob}installation-scripts'

resource vmCustomScript 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = [for (config, i) in items(configs): if (config.value.create && config.value.hasInstallationScript) {
  name: '${config.value.vMachineName}ext'
  parent: virtualMachines[i]
  location: location
  tags: {
    applicationId: applicationId
    owner: owner
    environment: environment
    provisioner: provisioner
    role: config.key
  }

  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: false
      fileUris: [
        '${installationScriptFolder}/${config.value.fileName}?${serviceSASToken}'
      ]
    }

    protectedSettings: {
      commandToExecute: config.value.commandToExecute
    }
  }
}]

output fqdns array = [for (config, i) in items(configs): pips[i].properties.dnsSettings.fqdn]
output sshCommands array = [for (config, i) in items(configs): 'ssh -i ./ssh/vm-keys ${adminUser}@${pips[i].properties.dnsSettings.fqdn}']
