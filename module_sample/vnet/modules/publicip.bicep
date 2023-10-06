@minLength(3)
param location string = resourceGroup().location
@minLength(3)
param publicIpAddressName string
@minLength(3)
param dnsLabelPrefix string
param owner string
param applicationId string
@allowed(['dev', 'test', 'prod'])
param environment string
@allowed(['terraform', 'arm', 'bicep', 'crossplane'])
param provisioner string

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpAddressName
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
      domainNameLabel: dnsLabelPrefix
    }

    idleTimeoutInMinutes: 4
  }
}

output publicIpAddressId string = publicIpAddress.id
