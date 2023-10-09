
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

param location string = resourceGroup().location
param vmName string
param computerName string
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
param vmSize string
param adminUser string
@secure()
param adminPasswordOrKey string
param virtualNetworkName string
param subnetName string
param networkSecurityGroupName string
param networkInterfaceName string
param publicIpAddressName string
param dnsLabelPrefix string

module securityGroup 'modules/sgroup.bicep' = {
  name: 'defaultSecurityGroup'
  params: {
    networkSecurityGroupName: networkSecurityGroupName
    location: location    
  }
}

module publicIPAddress 'modules/ip.bicep' = {
  name: 'defaultPublicIpAddress'
  params: {
    publicIPAddressName: publicIpAddressName
    location: location
    dnsLabelPrefix: dnsLabelPrefix
  }
}

module virtualNetwork 'modules/vnet.bicep' = {
  name: 'defaultVirtualNetwork'
  params: {
    virtualNetworkName: virtualNetworkName
    location: location
    subnetName: subnetName
  }
}

module virtualMachine 'modules/vm.bicep' = {
  name: 'virtualMachine'
  params: {
    vmName: vmName
    computerName: computerName
    location: location
    adminUserName: adminUser
    adminPasswordOrKey: adminPasswordOrKey
    vmSize: vmSize
    authenticationType: 'sshPublicKey'
    securityType: 'Standard'
    ubuntuOSImageVersion: ubuntuOSImageVersion
    publicIPAddressId: publicIPAddress.outputs.publicIPAddressId
    subNetId: virtualNetwork.outputs.subnetId
    networkSecurityGroupId: securityGroup.outputs.securityGroupId
    networkInterfaceName: networkInterfaceName
    tags: {
      applicationId: applicationId
      environment: environment
      owner: owner
      provisioner: provisioner
    }
  }
}

output adminUser string = adminUser
output hostname string = publicIPAddress.outputs.hostname
output sshCommand string = 'ssh -i ./ssh/vm-keys ${adminUser}@${publicIPAddress.outputs.hostname}'
