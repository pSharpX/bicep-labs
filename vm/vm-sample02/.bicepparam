using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'

param vmCount = 2
param vmSize = 'Standard_D2s_v3'
param adminUser = 'crivera'
param sshKey = loadTextContent('ssh/vm-keys.pub')
param imageVersion = 'Ubuntu-2204'

param virtualNetworkName = '${applicationId}_vnet'
param securityGroupName = '${applicationId}_nsg'
param defaultSubnetName = '${applicationId}_subnet'
param dnsLabelPrefix = applicationId
