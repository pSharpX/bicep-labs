using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'
param nicName = '${applicationId}_nic'
param vNetName = '${applicationId}_vnet'
param subnetName = '${applicationId}_subnet'
param securityGroupName = '${applicationId}_nsg'
param publicIpAddressName = '${applicationId}_pip'
param dnsLabelPrefix = applicationId
