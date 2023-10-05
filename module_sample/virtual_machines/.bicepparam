using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'

param vmName = 'vM_${applicationId}'
param ubuntuOSImageVersion = 'Ubuntu-2204'
param vmSize = 'Standard_D2s_v3'
param adminUser = 'crivera'
param adminPasswordOrKey = loadTextContent('ssh/vm-keys.pub')
param virtualNetworkName = 'vNet_${applicationId}'
param subnetName = 'subNet_${applicationId}'
param networkSecurityGroupName = 'sGroup_${applicationId}'
param publicIpAddressName = '${vmName}PublicIP'
param dnsLabelPrefix = applicationId
