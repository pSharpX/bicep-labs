using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'

param vmName = '${applicationId}_vm'
param computerName = '${applicationId}PC'
param ubuntuOSImageVersion = 'Ubuntu-2204'
param vmSize = 'Standard_D2s_v3'
param adminUser = 'crivera'
param adminPasswordOrKey = loadTextContent('ssh/vm-keys.pub')
param networkInterfaceName = '${applicationId}_nic'
param virtualNetworkName = '${applicationId}_vnet'
param subnetName = '${applicationId}_subnet'
param networkSecurityGroupName = '${applicationId}_nsg'
param publicIpAddressName = '${applicationId}_pip'
param dnsLabelPrefix = applicationId
