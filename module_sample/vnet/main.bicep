@minLength(3)
param location string = resourceGroup().location
param vNetName string
param owner string
param applicationId string
@allowed(['dev', 'test', 'prod'])
param environment string
@allowed(['terraform', 'arm', 'bicep', 'crossplane'])
param provisioner string
param addressPrefix string = '10.1.0.0/16'
param subnetName string
param subnetAddressPrefix string = '10.1.0.0/24'
@minLength(3)
param securityGroupName string
@minLength(3)
param publicIpAddressName string
@minLength(3)
param dnsLabelPrefix string
@minLength(3)
param nicName string

module virtualNetwork 'modules/vnet.bicep' = {
  name: 'defaultVirtualNetwork'
  params: {
    vNetName: vNetName
    location: location
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
    addressPrefix: addressPrefix
  }
}

module defaultSubnet 'modules/subnet.bicep' = {
  name: 'defaultSubnet'
  params: {
    subnetName: subnetName
    subnetAddressPrefix:subnetAddressPrefix
    virtualNetworkName: virtualNetwork.outputs.virtualNetworkName
  }
}

module defaultSecurityGroup 'modules/sgroup.bicep' = {
  name: 'defaultSecurityGroups'
  params: {
    securityGroupName: securityGroupName
    location: location
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

module defaultPublicIpAddress 'modules/publicip.bicep' = {
  name: 'defaultPublicIpAddress'
  params: {
    publicIpAddressName: publicIpAddressName
    dnsLabelPrefix: dnsLabelPrefix
    location: location
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}

module defaultNetworkInterface 'modules/nic.bicep' = {
  name: 'defaultNetworkInterface'
  params: {
    defaultSubnetId: defaultSubnet.outputs.defaultSubnetId
    securityGroupId: defaultSecurityGroup.outputs.securityGroupId
    nicName: nicName
    publicIpAddressId: defaultPublicIpAddress.outputs.publicIpAddressId
    location: location
    owner: owner
    applicationId: applicationId
    environment: environment
    provisioner: provisioner
  }
}
