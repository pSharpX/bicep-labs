using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'
param nicName = '${applicationId}Nic'
param vNetName = '${applicationId}vNet'
param subnetName = '${applicationId}SubNet01'
param securityGroupName = '${applicationId}SecGroup'
param publicIpAddressName = '${applicationId}PublicIP'
param dnsLabelPrefix = applicationId
