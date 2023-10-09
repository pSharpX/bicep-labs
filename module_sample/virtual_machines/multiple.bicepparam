using 'multiple.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'

param resourcePrefix = applicationId
param vmCount = 3
param ubuntuOSImageVersion = 'Ubuntu-2204'
param vmSize = 'Standard_D2s_v3'
param adminUser = 'crivera'
param adminPasswordOrKey = loadTextContent('ssh/vm-keys.pub')
param virtualNetworkName = '${applicationId}_vnet'
param subnetName = '${applicationId}_subnet'
param networkSecurityGroupName = '${applicationId}_nsg'
