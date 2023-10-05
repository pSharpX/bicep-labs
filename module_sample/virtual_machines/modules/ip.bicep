
@description('Location for all resources')
param location string = resourceGroup().location

@description('Public IP address to be assigned to virtual machine')
param publicIPAddressName string

@description('Unique DNS name for the public IP used to access the virtual machine')
param dnsLabelPrefix string

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Basic'
  }

  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion:'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }

    idleTimeoutInMinutes: 4
  }
}

output publicIPAddressId string = publicIPAddress.id
output hostname string = publicIPAddress.properties.dnsSettings.fqdn
