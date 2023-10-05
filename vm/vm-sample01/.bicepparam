using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'

param vmName = '${applicationId}vM'
param vmSize = 'Standard_D2s_v3'
param adminUser = 'crivera'
param sshKey = loadTextContent('ssh/vm-keys.pub')
param imageVersion = 'Ubuntu-2204'
param customData = loadFileAsBase64('config/cloud-init.yaml')


param networkInterfaceName = '${applicationId}Nic'
param vNetName = '${applicationId}vNet'
param subnetName = '${applicationId}SubNet01'
param securityGroupName = '${applicationId}SecGroup'
param publicIpAddressName = '${vmName}PublicIP'
param dnsLabelPrefix = applicationId
