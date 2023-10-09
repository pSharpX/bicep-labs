
@description('Application Identifier')
@minLength(3)
@maxLength(15)
param applicationId string

@description('Application owner for Technical Support')
param owner string

@description('Environment')
@allowed(['dev', 'test', 'uat', 'prod'])
param environment string

@allowed(['bicep', 'terraform', 'arm', 'crossplane'])
param provisioner string

@minLength(2)
@description('A prefix to be added to resources names')
param resourcePrefix string

@description('Location where all resources will be created')
param location string = resourceGroup().location

@allowed([
  'Ubuntu-1804'
  'Ubuntu-2004'
  'Ubuntu-2204'
])
@description('OS version for the Virtual Machine')
param ubuntuOSImageVersion string

@allowed([
  'Standard_B2s'
  'Standard_B2ms'
  'Standard_D2_v2'
  'Standard_D2s_v3'
  'Standard_DS2'
])
param vmSize string

@minValue(1)
@maxValue(4)
@description('Represents the number of Virtual Machine to be created')
param vmCount int

@minLength(5)
param adminUser string

@secure()
param adminPasswordOrKey string

@minLength(3)
param virtualNetworkName string

@minLength(3)
param subnetName string

@minLength(3)
param networkSecurityGroupName string

var configurations = [for i in range(0, vmCount): {
  vmName: '${resourcePrefix}_${uniqueString(resourceGroup().id, string(i))}_vm'
  computerName: '${applicationId}PC${padLeft(i+1, 3, '0')}'
  networkInterfaceName: '${resourcePrefix}_${uniqueString(resourceGroup().id, string(i))}_nic'
  publicIpAddressName: '${resourcePrefix}_${uniqueString(resourceGroup().id, string(i))}_pip'
  dnsLabelPrefix: '${applicationId}${uniqueString(resourceGroup().id, string(i))}'
}]

module securityGroup 'modules/sgroup.bicep' = {
  name: 'default_nsg'
  params: {
    networkSecurityGroupName: networkSecurityGroupName
    location: location    
  }
}

module publicIPAddress 'modules/ip.bicep' = [for config in configurations: {
  name: '${uniqueString(config.publicIpAddressName)}_pip'
  params: {
    publicIPAddressName: config.publicIpAddressName
    location: location
    dnsLabelPrefix: config.dnsLabelPrefix
  }
}]

module virtualNetwork 'modules/vnet.bicep' = {
  name: 'default_vnet'
  params: {
    virtualNetworkName: virtualNetworkName
    location: location
    subnetName: subnetName
  }
}

module virtualMachine 'modules/vm.bicep' = [for (config, i) in configurations: {
  name: '${uniqueString(config.vmName)}_vm'
  params: {
    vmName: config.vmName
    computerName: config.computerName
    location: location
    adminUserName: adminUser
    adminPasswordOrKey: adminPasswordOrKey
    vmSize: vmSize
    authenticationType: 'sshPublicKey'
    securityType: 'Standard'
    ubuntuOSImageVersion: ubuntuOSImageVersion
    publicIPAddressId: publicIPAddress[i].outputs.publicIPAddressId
    subNetId: virtualNetwork.outputs.subnetId
    networkSecurityGroupId: securityGroup.outputs.securityGroupId
    networkInterfaceName: config.networkInterfaceName
    tags: {
      applicationId: applicationId
      environment: environment
      owner: owner
      provisioner: provisioner
    }
  }
}]

output adminUser string = adminUser
output hostnames array = [for (config, i) in configurations: publicIPAddress[i].outputs.hostname]
output sshCommands array = [for (config, i) in configurations: 'ssh -i ./ssh/vm-keys ${adminUser}@${publicIPAddress[i].outputs.hostname}']
